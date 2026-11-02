extends CanvasLayer

@onready var result: PanelContainer = $EndScreen
@onready var result_title: Label = $EndScreen/VBoxContainer/Title
@onready var result_stats: Label = $EndScreen/VBoxContainer/Stats
@onready var retry: Button = $EndScreen/VBoxContainer/RetryButton
@onready var menu: Button = $EndScreen/VBoxContainer/MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry.pressed.connect(_restart)
	menu.pressed.connect(_menu)
	LevelManager.game_started_event.connect(_start)
	LevelManager.game_ended.connect(_end)

func _start() -> void:
	result.hide()

func _end(outcome: int) -> void:
	var star_container = result.get_node("VBoxContainer/StarContainer")
	if outcome == LevelManager.GameEnd.OTHER:
		result.hide()
		return
	result.show()
	if outcome == LevelManager.GameEnd.WON:
		result_title.text = "Larga na, Davao!"
		result_stats.text = "Level complete!   %s\nCacao %d/%d  •  Score %d" % ["★".repeat(LevelManager.get_stars()) + "☆".repeat(3 - LevelManager.get_stars()), LevelManager.collected, LevelManager.total_collectibles, LevelManager.score]
		star_container.display_stars(LevelManager.get_stars())
	else:
		result_title.text = "Maayo ang pagsulay"
		result_stats.text = "Don't give up."
		star_container.display_stars(0)
	retry.visible = outcome == LevelManager.GameEnd.LOST
	menu.grab_focus()

func _restart() -> void:
	InterfaceManager.do_on_transition(LevelManager.restart_level)

func _menu() -> void:
	InterfaceManager.do_on_transition(LevelManager.return_to_main_menu)
