shader_type canvas_item;
#include "pixelate.gdshaderinc"

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_size = 1.0;

vec4 pixel_sample(vec2 screen_uv) {
	return texture(SCREEN_TEXTURE, pixelate_uv(screen_uv));
}

void fragment() {
	vec2 uv = pixelate_uv(SCREEN_UV);
	vec2 pixel = 1.0 / screen_resolution;
	vec4 color = pixel_sample(uv);

	// Look around the current pixel for an opaque neighbor. This creates a
	// one-pixel outline around the alpha edge while keeping the image pixelated.
	float neighbor_alpha = 0.0;
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv + vec2(pixel.x, 0.0) * outline_size).a);
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv - vec2(pixel.x, 0.0) * outline_size).a);
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv + vec2(0.0, pixel.y) * outline_size).a);
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv - vec2(0.0, pixel.y) * outline_size).a);
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv + pixel * outline_size).a);
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv + vec2(pixel.x, -pixel.y) * outline_size).a);
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv + vec2(-pixel.x, pixel.y) * outline_size).a);
	neighbor_alpha = max(neighbor_alpha, pixel_sample(uv - pixel * outline_size).a);

	float outline = step(0.01, neighbor_alpha) * (1.0 - step(0.01, color.a));
	COLOR = mix(color, outline_color, outline * outline_color.a);
}
