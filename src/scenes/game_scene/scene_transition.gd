extends ColorRect

func _ready() -> void:
	pass
	
func _set_cutoff(v: float):
	material.set_shader_parameter("cutoff", v)
