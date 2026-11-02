class_name BlindAttackComponent
extends Component

var default_blind_duration: float = 3.0
var blind_duration: float = 3.0
var _effect: BlindnessEffect

func tick(enemy: Enemy_Entity, delta: float) -> void:
	var player := GameManager.player
	if not is_instance_valid(player) or player.global_position.distance_to(enemy.global_position) > 440:
		_release()
		blind_duration = default_blind_duration
		return
	blind_duration -= delta
	if blind_duration > 0:
		if not is_instance_valid(_effect) or _effect.is_queued_for_deletion():
			var effect := BlindnessEffect.new()
			effect.duration = default_blind_duration
			effect.add_source(self)
			_effect = player.add_status_effect(effect) as BlindnessEffect
	else:
		_release()
		if blind_duration <= -1.0:
			blind_duration = default_blind_duration

func _release() -> void:
	if is_instance_valid(_effect):
		_effect.remove_source(self)
	_effect = null

func _exit_tree() -> void:
	_release()
