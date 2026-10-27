shader_type canvas_item;

uniform vec4 inactive_color;
uniform vec2 movement;

varying vec4 vertex_color;
void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	uv += movement * TIME;
	vec4 col = texture(TEXTURE, uv);// * vertex_color;
	vec4 col_gray = vec4(vec3((col.r + col.g + col.b) / 3.0), 1.0);
	col = mix(col_gray, col, vertex_color.r);
	col *= mix(inactive_color, vec4(1), vertex_color.r);
	COLOR = col;
}
