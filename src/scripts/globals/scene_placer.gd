extends Node

var back_pixel_layer: Node
var level_objects: Node

func register_level_layers(back: Node, objects: Node) -> void:
	back_pixel_layer = back
	level_objects = objects

func bpx_add_child(node: Node) -> void:
	back_pixel_layer.add_child(node)

func level_add_child(node: Node) -> void:
	level_objects.add_child(node)
