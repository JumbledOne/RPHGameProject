shader_type canvas_item;
#include "res://assets/gfx/shader/pixelate.gdshaderinc"

uniform float cutoff = 0.0;

void fragment() {
	vec2 uv = pixelate_uv(SCREEN_UV);

	// Find the distance to center of screen
	uv -= vec2(0.5);
	uv.x /= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	float dist_to_center = length(uv - vec2(0));

	float alpha = step(cutoff, dist_to_center);
	vec4 col = vec4(0);
	col.a = alpha;
	COLOR = col;
}
