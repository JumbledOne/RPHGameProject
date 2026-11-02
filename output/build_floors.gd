extends SceneTree
func _initialize() -> void:
 var paths = ["res://scenes/base_level/base_level.tscn", "res://scenes/levels/level_1.tscn", "res://scenes/levels/level_1_b.tscn"]
 var output = {}
 for path in paths:
  if not ResourceLoader.exists(path): continue
  var level = load(path).instantiate()
  var tile = level.get_node("TileMapLayer")
  var rect = tile.get_used_rect()
  var left = mini(0, rect.position.x)
  var right = maxi(80, rect.end.x)
  for x in range(left,right):
   for y in range(4):
    tile.set_cell(Vector2i(x,y),0,Vector2i(1,0 if y==0 else 1))
  output[path] = Marshalls.raw_to_base64(tile.get("tile_map_data"))
  level.free()
 var file = FileAccess.open("H:/GodotProjects/rph-game/output/floor_data.json", FileAccess.WRITE)
 file.store_string(JSON.stringify(output))
 quit()
