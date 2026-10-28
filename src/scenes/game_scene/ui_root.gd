extends Node

func _ready() -> void:
	InterfaceManager.ui_requested.connect(_on_ui_requested)
	for e in get_children():
		e.visibility_changed.connect(_on_visibility_changed.bind(e))
		_on_visibility_changed(e)

func _on_ui_requested(node_name: String):
	var node: CanvasLayer = get_node(node_name)
	for e in get_children():
		e.visible = e == node

func _on_visibility_changed(child: CanvasLayer) -> void:
	child.process_mode = Node.PROCESS_MODE_INHERIT if child.visible else Node.PROCESS_MODE_DISABLED
