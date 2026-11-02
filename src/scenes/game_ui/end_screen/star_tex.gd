class_name StarTexture
extends TextureRect

const EMPTY_REGION := Rect2(128, 0, 64, 64)
const HALF_REGION := Rect2(64, 0, 64, 64)
const FULL_REGION := Rect2(0, 0, 64, 64)

func show_empty() -> void:
	_set_region(EMPTY_REGION)

func show_half() -> void:
	_set_region(HALF_REGION)

func show_full() -> void:
	_set_region(FULL_REGION)

func _set_region(region: Rect2) -> void:
	var atlas_texture := texture as AtlasTexture
	if atlas_texture == null:
		return
	atlas_texture = atlas_texture.duplicate() as AtlasTexture
	atlas_texture.region = region
	texture = atlas_texture
