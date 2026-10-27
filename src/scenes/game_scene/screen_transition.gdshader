shader_type canvas_item;

global uniform vec2 screen_resolution;
uniform float cutoff = 0.0;

void fragment() {
	// UV to screen coords then back again to pixelate
	vec2 screen_coords = screen_resolution * SCREEN_UV;
	screen_coords = floor(screen_coords);
	vec2 uv = screen_coords / screen_resolution;
	
	// Find the distance to center of screen
	uv -= vec2(0.5);
	uv.x /= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	float dist_to_center = length(uv - vec2(0));
	
	float alpha = step(cutoff, dist_to_center);
	vec4 col = vec4(0);
	col.a = alpha;
	COLOR = col;
}
