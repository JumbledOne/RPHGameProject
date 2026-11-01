extends TextureRect

var PLAYER_CLASSES: Array[PlayerClass] = [
	UrbanCharacter.new(),
	AtaCharacter.new(),
	BagoboCharacter.new(),
]
const WALK_FRAMES: int = 3
const FRAME_TIME: float = 0.22

@onready var sprite: Sprite2D = $Sprite2D
@onready var title_label: Label = %PlayerClassTitleLabel
@onready var description_label: Label = %DescriptionLabel

var selected_index: int = 0
var animation_time: float = 0.0
var frame_index: int = 0

func _ready() -> void:
	selected_index = _find_selected_class()
	sprite.position = size * 0.5
	get_parent().get_node("HBoxContainer/ButtonLeft").pressed.connect(_select_previous)
	get_parent().get_node("HBoxContainer/ButtonRight").pressed.connect(_select_next)
	$Button.pressed.connect(_select_next)
	_update_display()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_instance_valid(sprite):
		sprite.position = size * 0.5

func _process(delta: float) -> void:
	animation_time += delta
	var next_frame: int = int(animation_time / FRAME_TIME) % WALK_FRAMES
	if next_frame != frame_index:
		frame_index = next_frame
		_update_sprite_frame()

func _select_previous() -> void:
	selected_index = posmod(selected_index - 1, PLAYER_CLASSES.size())
	_update_display()

func _select_next() -> void:
	selected_index = posmod(selected_index + 1, PLAYER_CLASSES.size())
	_update_display()

func _find_selected_class() -> int:
	for index in PLAYER_CLASSES.size():
		if PLAYER_CLASSES[index].get_script() == GameManager.player_class.get_script():
			return index
	return 0

func _update_display() -> void:
	var player_class: PlayerClass = PLAYER_CLASSES[selected_index]
	GameManager.player_class = player_class
	title_label.text = player_class.get_title()
	description_label.text = player_class.get_description()
	sprite.texture = player_class.get_sprite_sheet()
	frame_index = 0
	animation_time = 0.0
	_update_sprite_frame()

func _update_sprite_frame() -> void:
	# The player class sheets share the same three-frame walk cycle layout.
	sprite.region_rect = Rect2(frame_index * 32, 192, 32, 64)
