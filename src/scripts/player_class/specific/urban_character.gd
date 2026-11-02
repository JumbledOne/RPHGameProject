class_name UrbanCharacter
extends PlayerClass

const SPRITE_SHEET: AtlasTexture = preload("res://assets/gfx/gfx_resources/atlas_textures/urban.tres")

func get_title() -> String:
	return "Urban"

func get_description() -> String:
	return "Standard urban character: balanced movement with no special buff."

func get_sprite_sheet() -> AtlasTexture:
	return SPRITE_SHEET

func apply_to_player(_entity: PlayerEntity) -> void:
	pass

func get_ability() -> PlayerAbility:
	return null
