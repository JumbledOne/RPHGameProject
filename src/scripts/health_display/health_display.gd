extends HBoxContainer

const FILLED_HEART: Texture2D = preload("res://assets/gfx/sprites/hearts1.png")
const EMPTY_HEART: Texture2D = preload("res://assets/gfx/sprites/hearts3.png")

var linked_entity: Entity

# # # # # # # ## # # #
# Entity linking
func link_entity(entity: Entity):
	if not entity:
		return
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
		remove_child(e)
		e.queue_free()
	for i in range(linked_entity.max_health):
		_create_health_unit()
	_update_health_display.call_deferred()	
	
func _update_health_display():
	var i: int = 0
	for e: Control in get_children():
		if i < linked_entity.health:
			_set_filled(e)
		else:
			_set_empty(e)
		i += 1
	
func _create_health_unit():
	var heart: TextureRect = TextureRect.new()
	heart.texture = EMPTY_HEART
	heart.custom_minimum_size = Vector2.ONE * 16
	heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(heart)
	
func _set_filled(unit: Control):
	(unit as TextureRect).texture = FILLED_HEART
	
func _set_empty(unit: Control):
	(unit as TextureRect).texture = EMPTY_HEART
