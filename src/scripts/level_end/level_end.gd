extends Node2D

var _triggered: bool = false
var _player: PlatformerEntity

# Also not not strictly good design but it works
func begin_end_level_sequence():
	if _triggered:
		return
	_triggered = true
	_player = GameManager.player
	var controller = _player.get_node_or_null("PlayerController")
	if controller:
		# queue_free is deferred, so stop the controller from overwriting movement right now
		controller.set_process_input(false)
		controller.set_process_unhandled_input(false)
		controller.set_physics_process(false)
		controller.queue_free()
	GameManager.player = null
	$"Bar".queue_free()
	get_tree().create_timer(2, true).timeout.connect(_go_next_level, CONNECT_ONE_SHOT)

func _physics_process(_delta: float) -> void:
	if _player and is_instance_valid(_player):
		_player.horizontal_movement = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not PlayerEntity:
		return
	begin_end_level_sequence()

func _go_next_level():
	# Go to main menu for now
	InterfaceManager.do_on_transition(
			InterfaceManager.open_ui.bind("MainMenu")
	)
