extends Node

var back_pixel_layer: Node
var level_objects: Node
var front_pixel_layer: Node

func register_level_layers(back: Node, objects: Node, front: Node) -> void:
	back_pixel_layer = back
	level_objects = objects
	front_pixel_layer = front

func bpx_add_child(node: Node) -> void:
	back_pixel_layer.add_child(node)

func level_add_child(node: Node) -> void:
	level_objects.add_child(node)

func fpx_add_child(node: Node) -> void:
	front_pixel_layer.add_child(node)
