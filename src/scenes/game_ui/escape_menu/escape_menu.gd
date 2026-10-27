extends Control

@onready var resume_button: Button = $Screens/MainButtons/Resume

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.pause_toggled.connect(_on_pause_toggled)
	_on_pause_toggled()

func _on_pause_toggled() -> void:
	visible = GameManager.is_paused

func _on_resume_pressed():
	hide()
	GameManager.set_pause.bind(false)

func _on_main_menu_pressed() -> void:
	InterfaceManager.do_on_transition(GameManager.return_to_main_menu)
