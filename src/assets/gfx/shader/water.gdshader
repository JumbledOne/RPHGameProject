shader_type canvas_item;
#include "pixelate.gdshaderinc"

uniform sampler3D noise_tex : repeat_enable, filter_nearest;
uniform float noise_scale = 16.0;
uniform vec3 noise_movement;

uniform sampler2D color_ramp;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

varying vec2 world_position;
void vertex() {
	world_position = floor((MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy);
}

void fragment() {
	vec2 pixel_screen_uv = pixelate_uv(SCREEN_UV);
	vec4 screen_col = texture(SCREEN_TEXTURE, pixel_screen_uv);

	// Noise
	vec3 noise_uv = vec3(world_position / noise_scale, 0.0);
	noise_uv += noise_movement * TIME;
	vec4 noise_col = texture(noise_tex, noise_uv);
	// Color Ramp
	float w = mix(screen_col.r, noise_col.r, 0.1);
	vec4 final_col = texture(color_ramp, vec2(w, 0.0));
	//
	//final_col.a = step(0.5, final_col.r);
	COLOR = final_col;
}
