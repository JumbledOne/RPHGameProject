shader_type canvas_item;

uniform sampler3D noise_tex : repeat_enable;
uniform float noise_scale = 16.0;
uniform vec3 noise_movement;

uniform sampler2D color_ramp;

varying vec2 world_position;
void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	world_position = floor(world_position);
}

void fragment() {
	// Height gradient
	vec4 col = vec4(1.0);
	col.r = smoothstep(-16.0, 64.0, world_position.y);
	// Noise
	vec3 noise_uv = vec3(world_position / noise_scale, 0.0);
	noise_uv += noise_movement * TIME;
	vec4 noise_col = texture(noise_tex, noise_uv);
	// Color Ramp
	vec4 final_col = texture(color_ramp, vec2(mix(col, noise_col, 0.1).r, 0.0));
	//
	COLOR = final_col;
}