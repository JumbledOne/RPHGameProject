class_name PlayerEntity
extends PlatformerEntity

@export_category("World")
@export var death_altitude: float = 128 # Below this point the player dies

# Action vars
var attack_action: PlayerAttack = PlayerAttack.new()
var ability_action: PlayerAbility

@onready var model: Node2D = $PlayerModel
			
func _ready() -> void:
	super()
	model.set_texture(GameManager.player_class.get_sprite_sheet())
	GameManager.player_class.apply_to_player(self)
	ability_action = GameManager.player_class.get_ability()
	GameManager.player = self

func hurt(amount: int = 1) -> void:
	super.hurt(amount)

func _physics_process(delta: float) -> void:
	super(delta)
	if position.y >= death_altitude:
		die()
	position.x = clamp(position.x, LevelManager.level_left_boundary + 16, LevelManager.level_right_boundary - 16)
	
# # # # # # # # # # # #
# Actions
func do_attack() -> void:
	attack_action.do(self)

func do_ability() -> void:
	if ability_action:
		ability_action.do(self)
