class_name RottenCacaoAttackComponent
extends Component

const set_timer: float = 10.0
var timer: float = set_timer
var is_timer_active: bool = true

func tick(_enemy: Enemy_Entity, delta: float) -> void:
	
	if not is_timer_active:
		return
	
	timer -= delta
	
	if timer <= 0.0:
		GameManager.player.hurt()
		timer = set_timer
