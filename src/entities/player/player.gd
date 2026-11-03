class_name PlayerEntity
extends PlatformerEntity

const STOMP_AUDIO := preload("res://assets/audio/sfx/stomp.wav")

@export_category("World")
@export var death_altitude: float = 128 # Below this point the player dies

# Action vars
var attack_action: PlayerAttack = PlayerAttack.new()
var ability_action: PlayerAbility
var durians: int = 0
var attack_cooldown: float = 0.0
@export var attack_projectile_scene: PackedScene = preload("res://level_objects/features/projectiles/durian.tscn")

@onready var model: Node2D = $PlayerModel
			
func _ready() -> void:
	super()
	model.set_texture(GameManager.player_class.get_sprite_sheet())
	GameManager.player_class.apply_to_player(self)
	ability_action = GameManager.player_class.get_ability()
	GameManager.player = self

func _physics_process(delta: float) -> void:
	var was_falling := velocity.y > 0.0
	attack_cooldown = maxf(attack_cooldown - delta, 0)
	super(delta)
	if was_falling:
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			var collider := collision.get_collider()
			if collision.get_normal().y < -0.5 and collider is Enemy_Entity and not collider.is_queued_for_deletion():
				force_jump()
				_play_stomp_audio()
				collider.hurt(1, Entity.DAMAGE_TYPES.STOMPED)
				break
	if position.y >= death_altitude:
		die()
	position.x = clamp(position.x, LevelManager.level_left_boundary + 16, LevelManager.level_right_boundary - 16)

func _play_stomp_audio() -> void:
	var audio_player := AudioStreamPlayer2D.new()
	audio_player.stream = STOMP_AUDIO
	audio_player.volume_db = -8.0
	audio_player.finished.connect(audio_player.queue_free)
	add_child(audio_player)
	audio_player.play()
	

func hurt(amount: int = 1, damage_type: DAMAGE_TYPES = DAMAGE_TYPES.GENERIC):
	super(amount, damage_type)
	InterfaceManager.camera_shake_requested.emit(4)
	
# # # # # # # # # # # #
# Actions
func do_attack() -> void:
	if durians <= 0 or attack_cooldown > 0:
		return
	var level := ScenePlacer.level_objects
	if is_instance_valid(level):
		durians -= 1
		attack_cooldown = 0.4
		var direction: float = 1.0 if model.last_facing_right else -1.0
		var projectile := attack_projectile_scene.instantiate() as Projectile
		projectile.launch(direction, true)
		level.add_child(projectile)
		projectile.global_position = global_position + Vector2(direction * 28, -8)

func eat_durian() -> void:
	if durians > 0 and health < max_health:
		durians -= 1
		heal(1)

func do_ability() -> void:
	if ability_action:
		ability_action.do(self)
