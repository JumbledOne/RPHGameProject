shader_type canvas_item;

uniform float water_height = 0.0;

uniform sampler3D noise_tex : repeat_enable, filter_nearest;
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
	vec4 height_col = vec4(1.0);
	height_col.r = smoothstep(-16.0 + water_height, 64.0 + water_height, world_position.y);
	
	// Noise
	vec3 noise_uv = vec3(world_position / noise_scale, 0.0);
	noise_uv += noise_movement * TIME;
	vec4 noise_col = texture(noise_tex, noise_uv);
	
	// Color Ramp
	float w = mix(height_col, noise_col, 0.1).r;
	w *= 16.0;
	w = floor(w);
	w /= 16.0;
	vec4 final_col = texture(color_ramp, vec2(w, 0.0));
	
	//
	final_col.a = step(0.1, w);
	COLOR = final_col;
}