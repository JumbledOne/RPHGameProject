extends HBoxContainer

var _animation_id := 0

func display_stars(count: int) -> void:
	_animation_id += 1
	var animation_id := _animation_id
	var stars: Array[StarTexture] = []
	for child in get_children():
		if child is StarTexture:
			stars.append(child)
			child.show_empty()
			child.scale = Vector2.ONE
			child.pivot_offset = child.size * 0.5
	for index in range(mini(count, stars.size())):
		if index > 0:
			await get_tree().create_timer(0.18).timeout
		if animation_id != _animation_id:
			return
		await _animate_star(stars[index])

func _animate_star(star: StarTexture) -> void:
	star.show_full()
	star.pivot_offset = star.size * 0.5
	star.scale = Vector2.ZERO
	var tween := star.create_tween()
	tween.tween_property(star, "scale", Vector2.ONE * 1.2, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(star, "scale", Vector2.ONE * 0.9, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(star, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
