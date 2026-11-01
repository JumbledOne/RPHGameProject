class_name UrbanCharacter
extends PlayerClass

const SPRITE_SHEET: AtlasTexture = preload("res://assets/gfx/gfx_resources/atlas_textures/urban.tres")

func get_title() -> String:
	return "Urban"

func get_description() -> String:
	return "A city-born survivor, ready to run through Davao's changing history."

func get_sprite_sheet() -> AtlasTexture:
	return SPRITE_SHEET

func get_ability() -> PlayerAbility:
	return SquareThrowAbility.new()
