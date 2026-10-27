shader_type canvas_item;
#include "pixelate.gdshaderinc"

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, pixelate_uv(SCREEN_UV));
}