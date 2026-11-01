class_name BagoboCharacter
extends PlayerClass

const SPRITE_SHEET: AtlasTexture = preload("res://assets/gfx/gfx_resources/atlas_textures/bagobo.tres")

func get_title() -> String:
	return "Bagobo Tagabawa"

func get_description() -> String:
	return "A Bagobo Tagabawa hero with deep roots in the Davao region."

func get_sprite_sheet() -> AtlasTexture:
	return SPRITE_SHEET

func get_ability() -> PlayerAbility:
	return SquareThrowAbility.new()
