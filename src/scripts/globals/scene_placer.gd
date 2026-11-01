extends Node

var back_pixel_layer: Node
var front_pixel_layer: Node
var level_objects: Node

func register_level_layers(back: Node, front: Node, objects: Node) -> void:
	back_pixel_layer = back
	front_pixel_layer = front
	level_objects = objects

func bpx_add_child(node: Node) -> void:
	back_pixel_layer.add_child(node)

func fpx_add_child(node: Node) -> void:
	front_pixel_layer.add_child(node)

func level_add_child(node: Node) -> void:
	level_objects.add_child(node)
