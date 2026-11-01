class_name PlayerAttack
extends PlayerAbility

const HitboxScene = preload("res://scripts/hitbox/hitbox.tscn")

var is_currently_attacking: bool = false

func do(doer: PlayerEntity) -> void:
	if is_currently_attacking:
		return
	
	is_currently_attacking = true
	
	var hitbox = HitboxScene.instantiate() as Hitbox
	hitbox.owner_node = doer
	doer.add_child(hitbox)
	
	# duration, shortened by the attack speed buff
	var duration: float = GameManager.base_attack_duration / GameManager.get_attack_speed()
	print("collected: ", GameManager.collected, " speed: ", GameManager.get_attack_speed(), " duration: ", duration)
	await doer.get_tree().create_timer(duration).timeout
	
	if is_instance_valid(hitbox):
		hitbox.queue_free()
		
	is_currently_attacking = false
