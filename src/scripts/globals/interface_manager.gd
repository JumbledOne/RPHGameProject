extends Node
# Can be called by GameManager but not the other way around

# UI switching
signal ui_requested(node_name: String)
func open_ui(node_name: String):
	ui_requested.emit(node_name)

# Camera shake
signal camera_shake_requested(amount: float)

# Scene transition
# Heavily relies on the SceneTransition on ScreenEffects
# Not strictly a good idea but it works
var doing_transition: bool = false
var call_on_transition: Callable
const TRANSITION_TIME: float = 2.0
signal transition_started
func do_on_transition(callable: Callable):
	if doing_transition:
		return
	doing_transition = true
	call_on_transition = callable
	get_tree().paused = true
	get_viewport().gui_disable_input = true
	transition_started.emit()
	
func transition_midpoint():
	call_on_transition.call()
	
func end_transition():
	doing_transition = false
	get_tree().paused = false
	get_viewport().gui_disable_input = false
