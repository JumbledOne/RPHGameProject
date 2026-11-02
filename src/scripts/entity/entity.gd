class_name Entity
extends CharacterBody2D
# Contains basic health logic

@export_category("Health")
@export var max_health: int = 3
@export var health: int = max_health:
	set(v):
		var new_health: int = clamp(v, 0, max_health)
		var health_diff: int = new_health - health
		health = new_health
		if health_diff < 0:
			damaged.emit()
		elif health_diff > 0:
			healed.emit()
		if health <= 0:
			die()

@export var damage_cooldown: float = 1.0
var can_damage: bool = true
var _damage_cooldown_remaining: float = 0.0

signal died
signal damaged
signal healed
signal status_effect_added(status_effect: StatusEffect)
signal status_effect_removed(status_effect: StatusEffect)

var _status_effects: Array[StatusEffect] = []

# # # # # # # # # # # #
# Health
func heal(amount: int = 1):
	health += amount

func hurt(amount: int = 1):
	if not can_damage:
		return
	can_damage = false
	_damage_cooldown_remaining = damage_cooldown
	health -= amount
	#print("player HP:" , health)

func _physics_process(delta: float) -> void:
	if not can_damage:
		_damage_cooldown_remaining = maxf(_damage_cooldown_remaining - delta, 0.0)
		if _damage_cooldown_remaining <= 0.0:
			can_damage = true
	
func die():
	if is_queued_for_deletion():
		return
	clear_status_effects()
	died.emit()
	queue_free()

# # # # # # # # # # # #
# Status Effect

func add_status_effect(effect: StatusEffect) -> StatusEffect:
	if effect == null or effect.is_queued_for_deletion() or is_queued_for_deletion():
		return null
	if effect.get_parent() != null and effect.get_parent() != self:
		push_error("Cannot apply a StatusEffect owned by another entity.")
		return null
	for current in _status_effects:
		if current.get_effect_key() == effect.get_effect_key():
			current.refresh_from(effect)
			if current != effect:
				effect.queue_free()
			return current
	if effect.get_parent() != null:
		push_error("Cannot apply a StatusEffect owned by another entity.")
		return null
	add_child(effect)
	return effect

func remove_status_effect(effect: StatusEffect) -> void:
	if is_instance_valid(effect) and effect in _status_effects:
		effect.finish()

func get_status_effect(effect_script: Script) -> StatusEffect:
	for effect in _status_effects:
		if effect.get_script() == effect_script:
			return effect
	return null

func has_status_effect(effect_script: Script) -> bool:
	return get_status_effect(effect_script) != null

func get_status_effects() -> Array[StatusEffect]:
	return _status_effects.duplicate()

func clear_status_effects() -> void:
	for effect in get_status_effects():
		remove_status_effect(effect)

func _register_status_effect(effect: StatusEffect) -> bool:
	for current in _status_effects:
		if current.get_effect_key() == effect.get_effect_key():
			current.refresh_from(effect)
			return false
	_status_effects.append(effect)
	return true

func _unregister_status_effect(effect: StatusEffect) -> void:
	if _status_effects.has(effect):
		_status_effects.erase(effect)
		status_effect_removed.emit(effect)

func _exit_tree() -> void:
	clear_status_effects()
