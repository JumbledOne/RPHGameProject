# Level objects

The five reusable base scripts live in `scripts/level_objects/`. Each concrete implementation has its own folder and scene in `level_objects/`. Generic demonstration scenes have been removed. Concrete scenes use native pixel sizes from the existing sprite atlas and bamboo texture, with no sprite or instance scaling. Driftwood uses atlas tile (1, 11), beside the water textures, and the same 32 by 8 collision strip as that tile. Only concrete final-plan instances are grouped under `LevelObjects/FeatureShowcase` in `scenes/levels/level_1_b.tscn`; run that scene with F6.

| Class | Behavior | Final-plan implementations |
| --- | --- | --- |
| StaticHazard | Player-only contact damage with a per-player cooldown | Spike barricade, barbed wire, road barrier |
| FallingHazard | Horizontal player proximity below the object triggers a shake warning, gravity drop, ground landing, then reset | Falling wooden crate, building/construction debris |
| MovingPlatform | Solid platform carries passengers between its placed origin and a relative destination | River-crossing boat (bamboo raft art), market crate (movement disabled) |
| HazardPlatform | Solid top and underside; only inset side strips deal damage and knockback | Moving car (jeepney art), rolling cart, rolling cannonball (knockback only) |
| FloatingPlatform | HazardPlatform motion plus sine-wave vertical bobbing | Floating driftwood (water-side atlas tile) |

Movement uses physics-synchronized AnimatableBody2D nodes. `travel_offset` is relative to the placed position; `travel_time` is the duration of each one-way trip. Movement reverses at the destination. `start_on_screen` delays a moving object's first trip until visible. Set `travel_offset` to zero for vertical bobbing in place. Set `moving` to false for stationary solid objects.

Damage calls the existing player `hurt(amount)` API. Zero damage still allows knockback for the less punishing rolling cannonball described in the plan. HazardPlatform scenes require a rectangular CollisionShape2D; side sensors derive from that rectangle at runtime and leave the top edge safe.

Falling hazards use `trigger_distance`, `warning_time`, `fall_gravity`, `terminal_speed`, and `reset_delay`. A shape cast stops the falling area at solid terrain while excluding the triggering player. Landed objects remain damaging until reset; market crates are the separate solid, climbable variant.

The plans' existing terrain and water mechanics remain in the level. Cannon/projectile firing is outside these five object classes. Dedicated boat and rubble art can replace the current reused textures without changing behavior.

Physics regression checks:

```text
godot --headless --path src --script res://tests/level_objects_test.gd
```
