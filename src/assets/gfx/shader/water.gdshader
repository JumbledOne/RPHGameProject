shader_type canvas_item;

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
	// Keep the shader's world-space lookup aligned to whole pixels. The varying
	// is interpolated across the ColorRect, so snapping in the vertex function
	// alone is not enough.
	vec2 pixel_world_position = floor(world_position);

	// The source texture supplies the water height in its red channel. This lets
	// the water shape be authored by the layer texture instead of fixed in the
	// shader.
	float water_height = texture(TEXTURE, UV).r;
	// Noise
	vec3 noise_uv = vec3(pixel_world_position / noise_scale, 0.0);
	noise_uv += noise_movement * TIME;
	vec4 noise_col = texture(noise_tex, noise_uv);
	// Color Ramp
	vec4 final_col = texture(color_ramp, vec2(mix(water_height, noise_col.r, 0.1), 0.0));
	//
	final_col.a = step(0.5, final_col.a);
	COLOR = final_col;
}
