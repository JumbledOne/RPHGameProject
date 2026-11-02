shader_type canvas_item;

uniform float grayscale_factor : hint_range(0.0, 1.0) = 1.0;

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	float grayscale = dot(texture_color.rgb, vec3(0.299, 0.587, 0.114));
	texture_color.rgb = mix(texture_color.rgb, vec3(grayscale), grayscale_factor);
	COLOR = texture_color * vertex_color;
}
