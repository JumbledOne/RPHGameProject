@abstract class_name Component
extends Node2D

@abstract func tick(enemy: Enemy_Entity, delta: float) -> void

signal animation_request(animation_name: String)
signal flip_sprite(direction: bool)
