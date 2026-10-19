class_name Cacao
extends Enemy_Entity

func _process(delta: float) -> void:
	attack_Component.tick(self, delta)
	pass

func _physics_process(delta: float) -> void:
	movement_Component.tick(self, delta)
	move_and_slide()
