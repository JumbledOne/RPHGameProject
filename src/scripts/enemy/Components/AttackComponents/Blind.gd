class_name BlindAttackComponent
extends Component

@onready var blind_overlay: ColorRect

var default_blind_duration: float = 3.0
var blind_duration: float = default_blind_duration
var is_attacking: bool = false

func _ready() -> void:
	blind_overlay = get_tree().get_first_node_in_group("blind_overlay")
	blind_overlay.visible = false

func tick(_enemy: Enemy_Entity, delta: float) -> void:
	if blind_overlay and blind_overlay.visible and GameManager.player:
		_updatePosition()
	
	blind(delta)

func blind(delta: float) -> void:
	if not blind_overlay:
		blind_overlay = get_tree().get_first_node_in_group("blind_overlay")
		
	if blind_overlay and blind_overlay.visible == false and !is_attacking:
		_updatePosition()
		blind_overlay.visible = true
		is_attacking = true
	
	blind_duration -= delta
	if blind_duration <= 0.0:
		blind_overlay.visible = false
	
	if blind_duration <= -3.0:
		blind_duration = default_blind_duration
		is_attacking = false

func _updatePosition() -> void:
	if not blind_overlay:
		blind_overlay = get_tree().get_first_node_in_group("blind_overlay")
	
	if blind_overlay and blind_overlay.material is ShaderMaterial:
		var viewport = get_viewport()
		var rect = viewport.get_visible_rect()
		
		var screen_pixel_pos = GameManager.player.get_global_transform_with_canvas().origin
		var normalized_screen_pos = screen_pixel_pos / rect.size
		
		var mat = blind_overlay.material as ShaderMaterial
		mat.set_shader_parameter("player_screen_position", normalized_screen_pos)
		
		var aspect_ratio = rect.size.x / rect.size.y
		mat.set_shader_parameter("screen_aspect", aspect_ratio)
