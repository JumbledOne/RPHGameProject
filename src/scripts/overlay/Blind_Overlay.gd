extends ColorRect

var entity: Node2D

func _process(_delta: float) -> void:
	if not is_visible_in_tree() or not is_instance_valid(entity):
		return
	var screen_size := get_viewport_rect().size
	if screen_size.x <= 0 or screen_size.y <= 0:
		return
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("player_screen_position", entity.get_global_transform_with_canvas().origin / screen_size)
	shader_material.set_shader_parameter("screen_aspect", screen_size.x / screen_size.y)
