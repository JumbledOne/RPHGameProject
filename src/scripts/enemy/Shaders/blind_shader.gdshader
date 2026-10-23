shader_type canvas_item;

uniform vec2 player_screen_position = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 1.0) = 0.15;
uniform float feather : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    float dist = distance(UV, player_screen_position);

    float alpha = smoothstep(radius, radius + feather, dist);

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}