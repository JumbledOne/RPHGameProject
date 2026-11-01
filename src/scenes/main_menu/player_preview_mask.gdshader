shader_type canvas_item;

uniform sampler2D gradient_mask : source_color;

void fragment() {
	vec4 player = texture(TEXTURE, UV) * COLOR;
	float mask_alpha = texture(gradient_mask, UV).a;
	COLOR = vec4(player.rgb, player.a * mask_alpha);
}
