extends Control

@onready var resume_button: Button = $Screens/MainButtons/Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	#resume_button.pressed.connect(GameManager.toggle_pause)
	GameManager.pause_toggled.connect(_on_pause_toggled)
	visible = get_tree().paused

func _on_pause_toggled(is_paused: bool) -> void:
	visible = is_paused
