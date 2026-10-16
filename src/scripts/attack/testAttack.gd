class_name PlayerAttack
extends BasePlayerAction

const HitboxScene = preload("res://scripts/hitbox/hitbox.tscn")

var is_currently_attacking: bool = false

func do(doer: Node2D) -> void:
	if is_currently_attacking:
		return
	
	is_currently_attacking = true
	
	var hitbox = HitboxScene.instantiate() as Hitbox

	hitbox.owner_node = doer
	
	doer.add_child(hitbox)
	
	#duration
	await doer.get_tree().create_timer(0.15).timeout
	
	if is_instance_valid(hitbox):
		hitbox.queue_free()
		
	if "player_action" in doer and doer.player_action == self:
		doer.player_action = null
		
	is_currently_attacking = false
