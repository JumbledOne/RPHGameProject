class_name Hurtbox
extends Area2D

@export var owner_node: Node2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(other_area: Area2D) -> void:
	
	if other_area is Hitbox:
		var attacker = other_area.owner_node
		
		if attacker == owner_node:
			return
			
		var target = owner_node
		if not target and get_parent():
			target = get_parent()
			
		if is_instance_valid(target) and target.has_method("hurt"):
			print("Hit confirmed on: ", target.name)
			target.hurt()
