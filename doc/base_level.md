# Base level node reference

Source scene: [`scenes/base_level/base_level.tscn`](../scenes/base_level/base_level.tscn)

`BaseLevel` is the reusable `Node2D` scene that provides the common structure for playable levels. Individual level scenes instance it and add level-specific art, terrain data, objects, and effects.

## Scene hierarchy

```text
BaseLevel (Node2D)                         base_level.gd
├── Background (instance)                  background/background.tscn
├── BackgroundEffects (Parallax2D)
│   ├── BackPixelLayer (CanvasGroup)       back_pixel_layer.gd
│   └── Fog (ColorRect)                    hidden by default
├── TileMapLayer (TileMapLayer)            level_tilemap.gd
├── LevelObjects (Node2D)
│   └── Items (TileMapLayer)                scene-collection tiles
├── FrontPixelLayer (CanvasGroup)          back/front pixelation material
├── PlayerCamera (Camera2D)                player_camera.gd
└── Player (instance)                      player/player.tscn
```

## Nodes

| Node path | Type | Purpose | Configuration / notes |
| --- | --- | --- | --- |
| `BaseLevel` | `Node2D` | Root of the reusable level container. | Runs `base_level.gd` on `_ready()`. |
| `Background` | `PackedScene` instance | Supplies the shared background artwork. | Uses a scroll offset of `(-9, 112)` in the base scene; levels may override it. |
| `BackgroundEffects` | `Parallax2D` | Holds background effects that move at a different rate from the world. | `z_index = -5`; `scroll_scale = (0.7, 1)`. Uses a pixelation material. |
| `BackgroundEffects/BackPixelLayer` | `CanvasGroup` | Back-layer container for background decorations and level-specific scenery. | `z_index = -5`; outlined/pixelated material. Level scenes commonly add sprites or `Line2D` children here. |
| `BackgroundEffects/Fog` | `ColorRect` | Optional full-area fog overlay. | Hidden in the base scene. Uses the fog shader, animated noise texture, gradient ramp, and a large rectangle covering the level area. |
| `TileMapLayer` | `TileMapLayer` | Main terrain and collision tile layer for the playable level. | Uses the shared level `TileSet`; runs `level_tilemap.gd` to calculate horizontal boundaries. Level scenes override its tile data. |
| `LevelObjects` | `Node2D` | Container for objects that belong to the level and should be registered as a gameplay layer. | Kept separate from terrain and render-only layers. |
| `LevelObjects/Items` | `TileMapLayer` | Places collectible and item scenes through a tile-set scene collection. | Base scene maps scene tiles for collectibles, durians, and honey jars. Level scenes override its tile data. |
| `FrontPixelLayer` | `CanvasGroup` | Foreground render layer for artwork that should appear in front of gameplay objects. | Uses the pixelation material and runs `front_pixel_layer.gd` (currently only declares `CanvasGroup`). |
| `PlayerCamera` | `Camera2D` | Camera used by the player during the level. | Runs `player_camera.gd`; the base scene provides the camera instance so every level has the same camera setup. |
| `Player` | `PackedScene` instance | Player character instance spawned into the level. | Starts at position `(16, -32)`; uses `player/player.tscn`. |

## Attached scripts

### `base_level.gd`

On `_ready()`, registers the level's render/gameplay layers with the autoloaded `ScenePlacer` singleton:

1. `BackgroundEffects/BackPixelLayer`
2. `LevelObjects`
3. `FrontPixelLayer`

Keep these node paths stable unless `base_level.gd` is updated as well. The registration order represents the intended back-to-front layer order.

### `level_tilemap.gd`

On `_ready()`, reads `get_used_rect()` from the main terrain tile map and calculates the level's horizontal bounds using the tile width:

- `GameManager.level_left_boundary = (used_rect.position.x + 1) * tile_width`
- `GameManager.level_right_boundary = (used_rect.position.x + used_rect.size.x - 1) * tile_width`

The one-tile inset keeps the playable boundary inside the outermost used terrain tiles. The calculation depends on the tile map having valid tile data and a configured tile set.

### `back_pixel_layer.gd` and `front_pixel_layer.gd`

Both scripts currently only extend `CanvasGroup`. Their main role is to give the two render layers dedicated script attachment points while the visual behavior is supplied by their materials and child nodes.

## Extending the base scene

Level scenes should instance `base_level.tscn` and override the existing nodes rather than duplicating the base hierarchy. For example, `scenes/levels/level_1_b.tscn`:

- instances `BaseLevel` as `Level1`;
- adds a `Water` scene at the level-specific location;
- adds tree and wood decorations under `BackgroundEffects/BackPixelLayer`;
- adds `SimpleFog` under `BackgroundEffects`;
- overrides `TileMapLayer` tile data for terrain;
- overrides `LevelObjects/Items` tile data for placed items.

When adding content, use these conventions:

- background decoration: `BackgroundEffects/BackPixelLayer`;
- optional fog or large background effect: `BackgroundEffects`;
- terrain and terrain collision: `TileMapLayer`;
- gameplay objects/items: `LevelObjects` or its `Items` tile layer;
- foreground decoration: `FrontPixelLayer`.

## Maintenance checklist

- If a required node is renamed or moved, update the `$...` paths in `base_level.gd`.
- If terrain dimensions change, confirm `TileMapLayer` still has a valid tile set and used rectangle.
- If a level adds an item scene, ensure its scene is represented in the `Items` tile-set collection.
- Keep foreground and background content in their respective pixel layers so draw order and parallax remain predictable.
