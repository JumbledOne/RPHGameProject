extends CanvasLayer

# makes the overlay invisible on start
@onready var blind_overlay: ColorRect

func _ready() -> void:
	blind_overlay = get_tree().get_first_node_in_group("blind_overlay")
	blind_overlay.visible = false
