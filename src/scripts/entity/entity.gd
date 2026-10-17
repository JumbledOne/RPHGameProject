class_name Entity
extends CharacterBody2D
# Contains basic health logic

@export_category("Health")
@export var max_health: int = 3
@export var health: int = max_health:
	set(v):
		var new_health: int = clamp(v, 0, max_health)
		var health_diff: int = new_health - health
		health = new_health
		if health_diff < 0:
			damaged.emit()
		elif health_diff > 0:
			healed.emit()
		if health <= 0:
			die()

# Action vars
var player_action: BasePlayerAction
			
signal died
signal damaged
signal healed

# # # # # # # # # # # #
# Health
func heal(amount: int = 1):
	health += amount

func hurt(amount: int = 1):
	health -= amount
	print("player HP:" , health)
	
func die():
	died.emit()
	queue_free()
