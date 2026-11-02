@abstract
class_name PlayerClass

# Flavor
@abstract func get_title() -> String
@abstract func get_description() -> String
@abstract func get_sprite_sheet() -> AtlasTexture

# 
@abstract func apply_to_player(entity: PlayerEntity)
@abstract func get_ability() -> PlayerAbility
