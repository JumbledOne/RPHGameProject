class_name PlayerEntity
extends PlatformerEntity

@export_category("World")
@export var death_altitude: float = 128 # Below this point the player dies

# Action vars
var attack_action: PlayerAttack = PlayerAttack.new()
var ability_action: PlayerAbility
var durians: int = 0
var eagle_charges: int = 0
var invulnerability: float = 0.0
var eagle_time: float = 0.0
var attack_cooldown: float = 0.0
var eagle_sprite: Sprite2D

@onready var model: Node2D = $PlayerModel
			
func _ready() -> void:
	super()
	model.set_texture(GameManager.player_class.get_sprite_sheet())
	GameManager.player_class.apply_to_player(self)
	ability_action = GameManager.player_class.get_ability()
	GameManager.player = self
	eagle_sprite = Sprite2D.new()
	eagle_sprite.texture = preload("res://assets/gfx/sprites/philippine_eagle_flying_idle_64x32.png")
	eagle_sprite.region_enabled = true
	eagle_sprite.region_rect = Rect2(0, 0, 32, 32)
	eagle_sprite.position = Vector2(0, -48)
	eagle_sprite.visible = false
	add_child(eagle_sprite)

func hurt(amount: int = 1) -> void:
	if invulnerability > 0 or is_queued_for_deletion():
		return
	invulnerability = 1.0
	super.hurt(amount)

func _physics_process(delta: float) -> void:
	invulnerability = maxf(invulnerability - delta, 0)
	attack_cooldown = maxf(attack_cooldown - delta, 0)
	model.modulate.a = 0.45 if invulnerability > 0 and int(invulnerability * 16) % 2 == 0 else 1.0
	if eagle_time > 0:
		eagle_time -= delta
		if eagle_time <= 0:
			jump_factor = 1.0
	eagle_sprite.visible = eagle_time > 0
	eagle_sprite.region_rect.position.x = int(eagle_time * 6) % 2 * 32
	super(delta)
	if position.y >= death_altitude:
		die()
	position.x = clamp(position.x, LevelManager.level_left_boundary + 16, LevelManager.level_right_boundary - 16)
	
# # # # # # # # # # # #
# Actions
func do_attack() -> void:
	if durians <= 0 or attack_cooldown > 0:
		return
	var level := get_tree().get_first_node_in_group("level_features")
	if is_instance_valid(level):
		durians -= 1
		attack_cooldown = 0.4
		var direction: float = 1.0 if model.last_facing_right else -1.0
		level.fire_projectile(global_position + Vector2(direction * 28, -8), direction, "durian", true)

func eat_durian() -> void:
	if durians > 0 and health < max_health:
		durians -= 1
		heal(1)

func do_ability() -> void:
	if eagle_charges > 0:
		eagle_charges -= 1
		eagle_time = 5.0
		jump_factor = 1.35
		velocity.y = -jump_velocity * jump_factor
		return
	if ability_action:
		ability_action.do(self)
