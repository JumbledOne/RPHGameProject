class_name GuaranteedHitAttackComponent
extends Component

const set_timer: float = 10.0
var timer: float = set_timer
var is_timer_active: bool = true
var is_attacking: bool = false

func tick(_enemy: Enemy_Entity, delta: float) -> void:
	
	if not is_timer_active:
		return
	
	timer -= delta
	
	if is_attacking and timer <= 0.0:
		timer = set_timer
		is_attacking = false
		animation_request.emit("default")
	
	if timer <= 0.0 and not is_attacking:
		GameManager.player.hurt()
		timer = 0.6 # 5fps in 3 frames
		is_attacking = true
		animation_request.emit("Left_attack")
