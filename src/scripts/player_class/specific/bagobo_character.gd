class_name BagoboCharacter
extends PlayerClass

const SPRITE_SHEET: AtlasTexture = preload("res://assets/gfx/gfx_resources/atlas_textures/bagobo.tres")
const JUMP_VELOCITY_MULTIPLIER: float = 0.8

func get_title() -> String:
	return "Bagobo Tagabawa"

func get_description() -> String:
	return "Bagobo-Tagabawa of Binugao: lower jumps, plus a second jump in midair."

func get_sprite_sheet() -> AtlasTexture:
	return SPRITE_SHEET

func apply_to_player(entity: PlayerEntity) -> void:
	entity.jump_velocity *= JUMP_VELOCITY_MULTIPLIER
	entity.max_midair_jumps = 1

func get_ability() -> PlayerAbility:
	return null
