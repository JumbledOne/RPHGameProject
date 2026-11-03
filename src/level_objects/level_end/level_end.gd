extends Node2D

const MAX_CACAO_REWARD: int = 20
# The endpoints of Bar's bar_movement animation, in local coordinates.
const BAR_BOTTOM_Y: float = -40.0
const BAR_TOP_Y: float = -256.0

var _triggered: bool = false
var _player: PlatformerEntity

# Also not not strictly good design but it works
func begin_end_level_sequence(bar_hit: bool) -> void:
	if _triggered:
		return
	_triggered = true
	$Bar/AnimationPlayer.pause()
	if bar_hit:
		LevelManager.add_bonus_cacao(get_cacao_reward())
		$CoinAudio.play_audio()
		$Bar/BarSprite.throw()
	_player = GameManager.player
	var controller = _player.get_node_or_null("PlayerController")
	if controller:
		# queue_free is deferred, so stop the controller from overwriting movement right now
		controller.set_process_input(false)
		controller.set_process_unhandled_input(false)
		controller.set_physics_process(false)
		controller.queue_free()
	GameManager.player = null
	get_tree().create_timer(2, true).timeout.connect(_go_next_level, CONNECT_ONE_SHOT)

func get_cacao_reward() -> int:
	var height_fraction := clampf(inverse_lerp(BAR_BOTTOM_Y, BAR_TOP_Y, $Bar.position.y), 0.0, 1.0)
	return roundi(height_fraction * MAX_CACAO_REWARD)

func _physics_process(_delta: float) -> void:
	if _player and is_instance_valid(_player):
		_player.horizontal_movement = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not PlayerEntity:
		return
	begin_end_level_sequence(false)

func _go_next_level():
	LevelManager.game_end(LevelManager.GameEnd.WON)
