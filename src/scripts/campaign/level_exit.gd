extends Area2D
@export var requires_boss: bool = true
var triggered := false
func _ready() -> void:
	body_entered.connect(_enter)
func _physics_process(_delta: float) -> void:
	# Handles defeating the boss after entering the exit's area.
	if LevelManager.boss_defeated and is_instance_valid(GameManager.player) and overlaps_body(GameManager.player):
		_enter(GameManager.player)
func _enter(body: Node2D) -> void:
	if triggered or not body is PlayerEntity or not LevelManager.game_started:
		return
	if requires_boss and not LevelManager.boss_defeated:
		return
	triggered = true
	LevelManager.game_end.call_deferred(LevelManager.GameEnd.WON)
