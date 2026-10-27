class_name AtaCharacter
extends PlayerClass

const SPRITE_SHEET: AtlasTexture = preload("res://assets/gfx/gfx_resources/atlas_textures/ata.tres")

func get_sprite_sheet() -> AtlasTexture:
	return SPRITE_SHEET

func get_ability() -> PlayerAttack:
	return null
