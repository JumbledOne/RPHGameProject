extends Node

func _ready() -> void:
	InterfaceManager.ui_requested.connect(_on_ui_requested)
	
func _on_ui_requested(node_name: String):
	var node: CanvasLayer = get_node(node_name)
	for e in get_children():
		e.visible = e == node
