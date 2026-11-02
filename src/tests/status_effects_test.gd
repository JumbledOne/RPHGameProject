extends Node

class CountingEffect extends StatusEffect:
	var applications := 0
	var removals := 0
	var ticks := 0
	func apply() -> void:
		applications += 1
	func remove() -> void:
		removals += 1
	func get_effect_duration() -> float:
		return 3.0
	func tick() -> void:
		ticks += 1

var failures := 0

func _ready() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func _run() -> void:
	var entity := Entity.new()
	add_child(entity)
	var events: Array[String] = []
	entity.status_effect_added.connect(func(_effect): events.append("added"))
	entity.status_effect_removed.connect(func(_effect): events.append("removed"))
	var counting := CountingEffect.new()
	entity.add_status_effect(counting)
	check(counting.applications == 1 and events == ["added"], "Application registers and emits once")
	counting._physics_process(2.4)
	check(counting.ticks == 2 and is_equal_approx(counting.get_remaining_time(), 0.6), "One-second ticks and duration are accurate")
	var duplicate := CountingEffect.new()
	check(entity.add_status_effect(duplicate) == counting, "Duplicate application returns the original effect")
	check(counting.applications == 1 and counting.get_remaining_time() == 3.0 and entity.get_status_effects().size() == 1, "Duplicate refresh does not stack or reapply")
	counting._physics_process(4.0)
	check(counting.ticks == 5 and counting.removals == 1 and events == ["added", "removed"], "Expiry ticks only within the effect duration and removes once")
	counting.finish()
	check(counting.removals == 1 and entity.get_status_effects().is_empty(), "Removal is idempotent")
	# Directly authored child effects use the same registry and duplicate handling.
	var authored := CountingEffect.new()
	entity.add_child(authored)
	entity.add_child(CountingEffect.new())
	check(entity.get_status_effects().size() == 1, "Authored child effects share the registry")
	entity.remove_status_effect(authored)
	check(entity.get_status_effects().is_empty(), "Manual removal unregisters immediately")
	var ui = preload("res://scenes/game_ui/game_ui.tscn").instantiate()
	add_child(ui)
	var displays = ui.get_node("StatusEffectDisplays")
	var overlay = displays.get_node("BlindOverlay")
	check(not overlay.visible, "Existing blind overlay starts hidden")
	displays.link_player(entity)
	var blind := BlindnessEffect.new()
	entity.add_status_effect(blind)
	check(displays.get_overlay(blind) == overlay and overlay.owner != null, "Type lookup returns the authored overlay")
	check(overlay.visible, "Adding blindness shows the existing overlay")
	check(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Blindness display does not intercept input")
	entity.add_status_effect(BlindnessEffect.new())
	check(overlay.visible, "Refreshed blindness keeps the same overlay")
	entity.remove_status_effect(blind)
	check(not overlay.visible, "Effect removal clears its display immediately")
	# Two enemies can contribute to one effect without clearing each other's blindness.
	var first_source := Node.new()
	var second_source := Node.new()
	add_child(first_source)
	add_child(second_source)
	var first := BlindnessEffect.new()
	first.add_source(first_source)
	entity.add_status_effect(first)
	var second := BlindnessEffect.new()
	second.add_source(second_source)
	entity.add_status_effect(second)
	first.remove_source(first_source)
	check(entity.has_status_effect(BlindnessEffect) and overlay.visible, "One caster cannot remove another caster's effect")
	second_source.queue_free()
	first._physics_process(0.01)
	check(not entity.has_status_effect(BlindnessEffect) and not overlay.visible, "Deleted caster releases blindness")
	first_source.queue_free()
	# Reconnects discover already-active effects and detach the previous player.
	var replacement := Entity.new()
	add_child(replacement)
	replacement.add_status_effect(BlindnessEffect.new())
	displays.link_player(replacement)
	check(overlay.visible, "Rebinding discovers existing effects")
	entity.add_status_effect(BlindnessEffect.new())
	entity.clear_status_effects()
	check(overlay.visible, "Old player signals no longer affect the UI")
	replacement.get_status_effect(BlindnessEffect)._physics_process(3.0)
	check(not overlay.visible, "Natural expiry removes the overlay")
	# Parent processing pauses effect timers too.
	var paused_effect := BlindnessEffect.new()
	replacement.add_status_effect(paused_effect)
	replacement.process_mode = Node.PROCESS_MODE_DISABLED
	await frames(5)
	check(paused_effect.get_remaining_time() == 3.0, "Paused entity freezes its effect timers")
	replacement.process_mode = Node.PROCESS_MODE_INHERIT
	# GameManager.player_set automatically links the actual PlayerEntity.
	var player = preload("res://entities/player/player.tscn").instantiate()
	add_child(player)
	player.set_physics_process(false)
	check(displays.player == player and not overlay.visible, "Player change automatically rebinds and clears the UI")
	player.add_status_effect(BlindnessEffect.new())
	check(overlay.visible, "Live player effect signal reaches GameUi")
	GameManager.player = null
	check(not overlay.visible, "Clearing the live player clears displays")
	# Death clears effects and their modifiers before notifying game logic.
	displays.link_player(replacement)
	replacement.die()
	check(replacement.get_status_effects().is_empty() and not overlay.visible, "Death cleans up active status effects")
	player.queue_free()
	entity.queue_free()
	ui.queue_free()
	await frames(3)
	print("Status effect tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	get_tree().quit(failures)
