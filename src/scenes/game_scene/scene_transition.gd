extends ColorRect

var anim_time: float
var tween: Tween

const MAX_CUTOFF: float = 2.0

func _ready() -> void:
	InterfaceManager.transition_started.connect(_on_transition_started)
	
func _on_transition_started(transition_length: float):
	anim_time = transition_length / 2
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_cutoff, MAX_CUTOFF, 0.0, anim_time)
	tween.finished.connect(_transition_midpoint, CONNECT_ONE_SHOT)
	
func _transition_midpoint():
	InterfaceManager.transition_midpoint()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(_set_cutoff, 0.0, MAX_CUTOFF, anim_time)
	tween.finished.connect(_transition_end, CONNECT_ONE_SHOT)
	
func _transition_end():
	InterfaceManager.end_transition()
	
# Cutoff = 0 Screen covered
# Cutoff = MAX_CUTOFF Screen visible
func _set_cutoff(v: float):
	material.set_shader_parameter("cutoff", v)
