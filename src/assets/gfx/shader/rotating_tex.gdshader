shader_type canvas_item;

uniform float movement = 0;

const vec2 pivot = vec2(0.5, 0.5);

varying vec4 vertex_color;
void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec2 uv = UV;

	// Rotates
	float rotation = movement * TIME;
	float sine = sin(rotation);
	float cosine = cos(rotation);

	uv -= pivot;
	vec2 new_uv = uv;
	new_uv.x = uv.x * cosine - uv.y * sine;
	new_uv.y = uv.x * sine + uv.y * cosine;
	new_uv += pivot;

	//
	COLOR = texture(TEXTURE, new_uv) * vertex_color;
}