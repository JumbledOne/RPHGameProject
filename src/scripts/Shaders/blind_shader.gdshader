shader_type canvas_item;

uniform vec2 player_screen_position = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 1.0) = 0.15;
uniform float feather : hint_range(0.0, 1.0) = 0.05;
uniform float screen_aspect = 1.7778; // Default to 16:9 aspect ratio

void fragment() {
    vec2 adjusted_uv = UV;
    adjusted_uv.x *= screen_aspect;
    
    vec2 adjusted_player_pos = player_screen_position;
    adjusted_player_pos.x *= screen_aspect;
    
    float dist = distance(adjusted_uv, adjusted_player_pos);
    float alpha = smoothstep(radius, radius + feather, dist);
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}