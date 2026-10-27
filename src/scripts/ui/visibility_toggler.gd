extends BaseButton

@export var target : Node

func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed():
	target.visible = !target.visible
