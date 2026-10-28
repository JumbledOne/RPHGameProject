extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not PlatformerEntity:
		return
	$"..".begin_end_level_sequence()
