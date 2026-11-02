extends Node

signal player_set
signal player_died
signal pause_toggled

const SCREEN_SIZE: Vector2 = Vector2(640, 360)

var player_class: PlayerClass = UrbanCharacter.new()
var player: PlayerEntity:
	set(v):
		if is_instance_valid(player) and is_instance_valid(v):
			push_error("Attempt to link player when one already exists")
			return
		if is_instance_valid(player):
			player.died.disconnect(_on_player_died)
		player = v
		if is_instance_valid(player):
			player.died.connect(_on_player_died)
		player_set.emit()

var is_paused: bool = false

func _ready() -> void:
	LevelManager.game_started_event.connect(_update_cursor_state)
	LevelManager.game_ended.connect(func(_result): _update_cursor_state())
	_update_cursor_state()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and LevelManager.game_started and not InterfaceManager.doing_transition:
		toggle_pause()

func toggle_pause() -> void:
	set_pause(not is_paused)

func set_pause(value: bool) -> void:
	is_paused = value
	_update_cursor_state()
	pause_toggled.emit()

func _update_cursor_state(_unused = null) -> void:
	if LevelManager.game_started and not is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_player_died() -> void:
	player_died.emit()
	LevelManager.lose_life()
