shader_type canvas_item;
#include "pixelate.gdshaderinc"



void fragment() {
	vec2 uv = pixelate_uv(SCREEN_UV);
	
	uv -= vec2(0.5);
	float dist_to_center = length(uv);
	
	vec4 col = vec4(0);
	col.a = smoothstep(0.0, 2.0, dist_to_center);;
	COLOR = col;
}
