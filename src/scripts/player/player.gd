class_name PlayerEntity
extends PlatformerEntity

@export_category("World")
@export var death_altitude: float = 128 # Below this point the player dies
	
# # # # # # # # # # # #
# Actions
func do_action():
	if player_action:
		player_action.do(self)
