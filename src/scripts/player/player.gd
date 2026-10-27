class_name PlayerEntity
extends PlatformerEntity

@export_category("World")
@export var death_altitude: float = 128 # Below this point the player dies

# Action vars
var player_action: BasePlayerAction
			
func _ready() -> void:
	super()
	GameManager.player = self

func _physics_process(delta: float) -> void:
	super(delta)
	if position.y >= death_altitude:
		die()
	position.x = clamp(position.x, GameManager.level_left_boundary + 16, GameManager.level_right_boundary - 16)
	
# # # # # # # # # # # #
# Actions
func do_action():
	if player_action:
		player_action.do(self)
