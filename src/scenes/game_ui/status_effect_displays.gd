extends Control
## Existing overlays are shown or hidden by player status-effect signals.
var player: Entity
@onready var blind_overlay: ColorRect = $BlindOverlay

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameManager.player_set.connect(_on_player_set)
	LevelManager.game_ended.connect(_on_game_ended)
	_on_player_set()

func _on_player_set() -> void:
	link_player(GameManager.player)

func link_player(value: Entity) -> void:
	_disconnect_player()
	_hide_overlays()
	player = value
	blind_overlay.entity = value
	if not is_instance_valid(player):
		return
	player.status_effect_added.connect(_on_effect_added)
	player.status_effect_removed.connect(_on_effect_removed)
	player.tree_exiting.connect(_on_player_exiting)
	# Effects may have been applied before this UI was created or reconnected.
	for effect in player.get_status_effects():
		_on_effect_added(effect)

func get_overlay(status_effect: StatusEffect) -> Control:
	if status_effect is BlindnessEffect:
		return blind_overlay
	return null

func _on_effect_added(effect: StatusEffect) -> void:
	var overlay := get_overlay(effect)
	if overlay != null:
		overlay.show()

func _on_effect_removed(effect: StatusEffect) -> void:
	var overlay := get_overlay(effect)
	if overlay != null:
		overlay.hide()

func _on_player_exiting() -> void:
	link_player(null)

func _on_game_ended(_result: int) -> void:
	_hide_overlays()

func _hide_overlays() -> void:
	for overlay: Control in get_children():
		overlay.hide()

func _disconnect_player() -> void:
	if not is_instance_valid(player):
		return
	if player.status_effect_added.is_connected(_on_effect_added):
		player.status_effect_added.disconnect(_on_effect_added)
	if player.status_effect_removed.is_connected(_on_effect_removed):
		player.status_effect_removed.disconnect(_on_effect_removed)
	if player.tree_exiting.is_connected(_on_player_exiting):
		player.tree_exiting.disconnect(_on_player_exiting)

func _exit_tree() -> void:
	_disconnect_player()
