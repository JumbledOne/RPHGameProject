extends Node

var linked_entity: Entity

# Health textures
# TODO Refactor to actually use these values
@export var filled_heart: Texture2D
@export var empty_heart: Texture2D

# # # # # # # ## # # #
# Entity linking
func link_entity(entity: Entity):
	if linked_entity:
		linked_entity.healed.disconnect(_update_health_display)
		linked_entity.damaged.disconnect(_update_health_display)
	entity.healed.connect(_update_health_display)
	entity.damaged.connect(_update_health_display)
	linked_entity = entity
	_initialize_entity_health_disp()

# # # # # # # ## # # #
# Health displaying
func _initialize_entity_health_disp():
	# Clear previous
	for e: Control in get_children():
		e.queue_free()
	for i in range(linked_entity.max_health):
		_create_health_unit()
	_update_health_display()	
	
func _update_health_display():
	var i: int = 0
	for e: Control in get_children():
		if i < linked_entity.health:
			_set_filled(e)
		else:
			_set_empty(e)
		i += 1
	
func _create_health_unit():
	var c_rect: ColorRect = ColorRect.new()
	c_rect.custom_minimum_size = Vector2.ONE * 8
	add_child(c_rect)
	
func _set_filled(unit: Control):
	unit.color = Color.RED
	
func _set_empty(unit: Control):
	unit.color = Color.BLACK
