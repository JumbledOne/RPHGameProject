shader_type canvas_item;

uniform sampler2D noise_tex : repeat_enable, filter_nearest;
uniform float noise_scale = 16.0;
uniform vec2 noise_movement;
uniform vec2 noise_movement_2;
uniform float max_height = 128; // Used on smoothstep and multiplied on the col before the color ramp
uniform float color_step = 10.0;

uniform sampler2D color_ramp;

varying vec2 world_position;
void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_position = floor(world_position);
}

void fragment() {
	// Match the pixel-snapped lookup used by the water shader.
	vec2 pixel_world_position = floor(world_position);

	// Sample the same noise in opposite directions, then average the samples
	// before using the result as the color-ramp lookup.
	vec2 noise_uv = pixel_world_position / noise_scale;
	vec4 noise_col_a = texture(noise_tex, noise_uv + noise_movement * TIME);
	vec4 noise_col_b = texture(noise_tex, noise_uv - noise_movement_2 * TIME);
	vec4 noise_col = (noise_col_a + noise_col_b) * 0.5;

	// Color Ramp
	float w = noise_col.r;
	w = mix(w, smoothstep(max_height, 0.0, world_position.y), 0.5);
	//w *= color_step;
	//w = floor(w);
	//w /= color_step;
	
	
	vec4 final_col = texture(color_ramp, vec2(w, 0.0));
	COLOR = final_col;
}
