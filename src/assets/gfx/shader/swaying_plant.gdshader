shader_type canvas_item;
#include "pixelate.gdshaderinc"

global uniform float time_step;

uniform sampler2D noise_tex : repeat_enable, filter_nearest;
uniform float noise_scale = 128.0;
uniform vec2 noise_movement = vec2(-0.01, -0.01);
uniform float sway_strength = 2.0;

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	vec2 pixel_world_position = floor(world_position);
	vec2 noise_uv = pixel_world_position / noise_scale;

	// Use two moving samples, as with the fog, so the plant motion is less
	// repetitive while remaining deterministic across the sprite.
	float time = floor(TIME * time_step) / time_step;
	float noise_a = texture(noise_tex, noise_uv + noise_movement * time).r;
	float sway = noise_a * 2.0 - 1.0;

	// UV.y is 0 at the top and 1 at the bottom. Keep the roots fixed and
	// increase the displacement toward the tip of the plant.
	float sway_weight = 1.0 - UV.y;
	VERTEX.x += sway * sway_strength * sway_weight;
}



void fragment() {
	COLOR = texture(TEXTURE, UV);
}
