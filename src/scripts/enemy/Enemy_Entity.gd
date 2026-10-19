@abstract class_name Enemy_Entity
extends Entity

# should be called inside func _process()
@onready var attack_Component = $AttackComponent

# should be called inside func _physics_process()
# so movement is just handling how they move while attack components shouldn't be moving the entity
@onready var movement_Component = $MovementComponent

@export_category("speed")
@export var speed = 200.0
