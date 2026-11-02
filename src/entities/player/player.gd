class_name PlayerEntity
extends PlatformerEntity

@export_category("World")
@export var death_altitude: float = 128 # Below this point the player dies

# Action vars
var attack_action: PlayerAttack = PlayerAttack.new()
var ability_action: PlayerAbility
var durians: int = 0
var attack_cooldown: float = 0.0

@onready var model: Node2D = $PlayerModel
			
func _ready() -> void:
	super()
	model.set_texture(GameManager.player_class.get_sprite_sheet())
	GameManager.player_class.apply_to_player(self)
	ability_action = GameManager.player_class.get_ability()
	GameManager.player = self

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(attack_cooldown - delta, 0)
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
	if ability_action:
		ability_action.do(self)
