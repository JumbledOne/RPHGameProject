extends CanvasLayer

@onready var result: EndScreen = $EndScreen
@onready var stats_bar: HBoxContainer = $StatsBar
@onready var result_title: Label = $EndScreen/VBoxContainer/Title
@onready var next_level: Button = $EndScreen/VBoxContainer/NextLevelButton
@onready var retry: Button = $EndScreen/VBoxContainer/RetryButton
@onready var menu: Button = $EndScreen/VBoxContainer/MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	next_level.pressed.connect(_next_level)
	retry.pressed.connect(_restart)
	menu.pressed.connect(_menu)
	LevelManager.game_started_event.connect(_start)
	LevelManager.game_ended.connect(_end)

func _start() -> void:
	result.hide_screen()
	stats_bar.show()

func _end(outcome: int) -> void:
	var star_container = result.get_node("VBoxContainer/StarContainer")
	if outcome == LevelManager.GameEnd.OTHER:
		result.hide_screen()
		return
	stats_bar.hide()
	if outcome == LevelManager.GameEnd.WON:
		result_title.text = "Larga na, Davao!"
		star_container.display_stars(LevelManager.get_stars())
	else:
		result_title.text = "Maayo ang pagsulay"
		star_container.display_stars(0)
	next_level.visible = outcome == LevelManager.GameEnd.WON and LevelManager.current_level + 1 < LevelManager.get_level_count()
	result.animate_in()
	if next_level.visible:
		next_level.grab_focus()
	else:
		retry.grab_focus()

func _next_level() -> void:
	InterfaceManager.do_on_transition(LevelManager.start_game.bind(LevelManager.current_level + 1))

func _restart() -> void:
	InterfaceManager.do_on_transition(LevelManager.restart_level)

func _menu() -> void:
	InterfaceManager.do_on_transition(LevelManager.return_to_main_menu)
