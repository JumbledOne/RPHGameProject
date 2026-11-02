class_name AtaCharacter
extends PlayerClass

const SPRITE_SHEET: AtlasTexture = preload("res://assets/gfx/gfx_resources/atlas_textures/ata.tres")
const JUMP_VELOCITY_MULTIPLIER: float = 1.2
const JUMP_TIME_MULTIPLIER: float = 0.65

func get_title() -> String:
	return "Ata"

func get_description() -> String:
	return "An Ata of Paquibato, carrying the strength of their homeland."

func get_sprite_sheet() -> AtlasTexture:
	return SPRITE_SHEET

func apply_to_player(entity: PlayerEntity) -> void:
	entity.jump_velocity *= JUMP_VELOCITY_MULTIPLIER
	entity.max_jump_time *= JUMP_TIME_MULTIPLIER

func get_ability() -> PlayerAbility:
	return null
