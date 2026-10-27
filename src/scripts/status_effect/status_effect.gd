@abstract
class_name StatusEffect
extends Node

@onready var entity: Entity = $".."

func _ready() -> void:
	apply()

func _exit_tree() -> void:
	remove()

@abstract func apply()
@abstract func remove()
