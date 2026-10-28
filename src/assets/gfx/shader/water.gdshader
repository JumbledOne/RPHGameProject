shader_type canvas_item;
#include "pixelate.gdshaderinc"

uniform sampler3D noise_tex : repeat_enable, filter_nearest;
uniform float noise_scale = 16.0;
uniform vec3 noise_movement;
uniform float noise_influence = 0.1;

uniform sampler2D color_ramp;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform vec4 outline_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_size = 1.0;

float water_alpha_at(vec2 sample_screen_uv, vec2 sample_world_position) {
	vec4 sample_screen_col = texture(SCREEN_TEXTURE, sample_screen_uv);
	vec3 sample_noise_uv = vec3(sample_world_position / noise_scale, 0.0);
	sample_noise_uv += noise_movement * TIME;
	float sample_w = mix(sample_screen_col.r, texture(noise_tex, sample_noise_uv).r, noise_influence);
	return texture(color_ramp, vec2(sample_w, 0.0)).a;
}

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
	float w = mix(screen_col.r, noise_col.r, noise_influence);
	vec4 final_col = texture(color_ramp, vec2(w, 0.0));

	// Make the water alpha binary before calculating the outline.
	float water_alpha = step(0.5, final_col.a);
	final_col.a = water_alpha;

	// Add an outside outline wherever a transparent pixel borders water.
	vec2 outline_uv = vec2(outline_size) / screen_resolution;
	float neighbor_alpha = max(
		max(
			water_alpha_at(pixelate_uv(SCREEN_UV + vec2(outline_uv.x, 0.0)), world_position + vec2(outline_size, 0.0)),
			water_alpha_at(pixelate_uv(SCREEN_UV - vec2(outline_uv.x, 0.0)), world_position - vec2(outline_size, 0.0))
		),
		max(
			water_alpha_at(pixelate_uv(SCREEN_UV + vec2(0.0, outline_uv.y)), world_position + vec2(0.0, outline_size)),
			water_alpha_at(pixelate_uv(SCREEN_UV - vec2(0.0, outline_uv.y)), world_position - vec2(0.0, outline_size))
		)
	);
	float outline_alpha = (1.0 - water_alpha) * neighbor_alpha;
	COLOR = mix(final_col, outline_color, outline_alpha);
}
