extends Label

var time_left: float = LevelManager.MAX_LEVEL_TIME
var level_active: bool = false

func _ready() -> void:
	LevelManager.game_started_event.connect(_on_game_started)
	LevelManager.game_ended.connect(_on_game_ended)
	GameManager.pause_toggled.connect(_on_pause_toggled)
	_on_game_started()
	_update_label()

func _process(delta: float) -> void:
	if not level_active or GameManager.is_paused:
		return
	if LevelManager.time_limit <= 0:
		text = "—"
		return
	time_left = LevelManager.get_time_left()
	_update_label()

func _on_game_started() -> void:
	time_left = LevelManager.MAX_LEVEL_TIME
	level_active = true
	_update_label()

func _on_game_ended(_result: int) -> void:
	level_active = false

func _on_pause_toggled() -> void:
	set_process(not GameManager.is_paused)

func _update_label() -> void:
	var seconds: int = ceili(time_left)
	text = str(seconds)
