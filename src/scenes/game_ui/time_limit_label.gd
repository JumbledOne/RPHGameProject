extends Label

var time_left: float = GameManager.MAX_LEVEL_TIME
var level_active: bool = false

func _ready() -> void:
	GameManager.game_started_event.connect(_on_game_started)
	GameManager.game_ended.connect(_on_game_ended)
	GameManager.pause_toggled.connect(_on_pause_toggled)
	_on_game_started()
	_update_label()

func _process(delta: float) -> void:
	if not level_active or GameManager.is_paused:
		return

	time_left = maxf(time_left - delta, 0.0)
	_update_label()
	if time_left <= 0.0:
		level_active = false
		if is_instance_valid(GameManager.player):
			GameManager.player.hurt(GameManager.player.health)

func _on_game_started() -> void:
	time_left = GameManager.MAX_LEVEL_TIME
	level_active = true
	_update_label()

func _on_game_ended(_result: int) -> void:
	level_active = false

func _on_pause_toggled() -> void:
	set_process(not GameManager.is_paused)

func _update_label() -> void:
	var seconds: int = ceili(time_left)
	text = "%02d:%02d" % [seconds / 60, seconds % 60]
