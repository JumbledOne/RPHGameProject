shader_type canvas_item;

uniform vec2 movement;

varying vec4 vertex_color;
void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	uv += movement * TIME;
	COLOR = texture(TEXTURE, uv) * vertex_color;
}
