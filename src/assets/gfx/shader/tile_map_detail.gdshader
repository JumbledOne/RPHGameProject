shader_type canvas_item;

uniform sampler2D detail_tex : repeat_enable, filter_nearest;
uniform float scale = 128.0;

uniform float max_height = -128.0;
uniform float darken_strength = 0.5;

varying vec2 world_position;
void vertex() {
	world_position = floor((MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy);
}

void fragment() {
	vec2 world_uv = world_position / scale;
	// Use the detail texture as a darkening mask, bounded by the height fade.
	float detail = texture(detail_tex, world_uv).r;
	float height_mask = smoothstep(max_height, 0.0, world_position.y);
	vec4 tile = texture(TEXTURE, UV);
	float darkening = 1.0 - detail * height_mask * darken_strength;
	vec4 final_col = vec4(tile.rgb * darkening, tile.a);
	COLOR = final_col;
}
