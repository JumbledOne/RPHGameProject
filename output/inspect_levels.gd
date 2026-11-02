extends SceneTree
func _initialize() -> void:
 for i in range(2,6):
  var scene = load("res://scenes/levels/level_%d.tscn" % i).instantiate()
  var tile = scene.get_node("TileMapLayer")
  var rows = {}
  for cell in tile.get_used_cells():
   var data=tile.get_cell_tile_data(cell)
   if data and tile.tile_set.get_physics_layers_count()>0 and data.get_collision_polygons_count(0)>0:
    if not rows.has(cell.y): rows[cell.y]=[]
    rows[cell.y].append(cell.x)
  var row=0
  for y in rows:
   if not rows.has(row) or rows[y].size()>rows[row].size():row=y
  var xs=rows.get(row,[])
  xs.sort()
  print(i," tiles=",tile.tile_set.tile_size," rect=",tile.get_used_rect()," row=",row," x=",xs)
  scene.free()
 quit()
