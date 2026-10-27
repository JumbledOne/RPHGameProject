// Snaps screen-space UVs to the game's pixel grid.
// Requires `global uniform vec2 screen_resolution;` to be declared by the including shader.

global uniform vec2 screen_resolution;
vec2 pixelate_uv(vec2 screen_uv) {
	vec2 screen_coords = floor(screen_resolution * screen_uv);
	return screen_coords / screen_resolution;
}
