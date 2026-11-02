### **Stage 1**

Floating Driftwood: Logs float towards the player and must be jumped over.

* Decent platforming challenge. It’s fine since the water makes mistakes less harsh.

~~Strong River Currents: Push the player backward, slowing movement.~~

* River mechanics are an entirely new thing	

~~Falling Fruit: Drop from trees at random intervals.~~

* Too hard for the first level

~~Mangrove Roots: roots that block the path, requiring jumping or sliding.~~

* Sliding isn’t implemented and there are no animations for it.

~~Broken Bridges: collapse shortly after being stepped on.~~

* No assets for this

~~Moving Trading Boats: Boats cross the player's path, requiring precise timing.~~

* No assets for this

~~Muddy Riverbanks: Reduce movement speed and jumping distance.~~

* No assets and it doesn’t contribute a lot of interesting choices in gameplay. Reduces the player’s options when the player doesn’t have many options to begin with at this stage. Also requires too much refactoring on the entity movement.

~~Thorny Forest Vines: Damage players who touch them.~~

* This isn’t used later

~~Special obstacle: Rising Tide — Water will rise gradually.~~

* Too much stress for the first level when the player should be learning the mechanics

### **Stage 2**

**Possible Obstacles & Enemies:**

Rolling Cannonballs: Roll across the ground and must be jumped over.

* Since they are small, they should push you instead of killing you to make it less punishing.

Cannon Fire: Projectiles follow a predictable arc, requiring dodging.

* Yes but no arc since the cannon asset is only facing left

~~Wooden Barricades: Block pathways and can be destroyed using weapons.~~

* No reason to exist if bypassing it is trivial.

~~Falling Fort Debris: Wooden beams fall from damaged structures.~~

* No assets for this

Spike Barricades: Require jumping or finding an alternative path.

* Yes but still indistinguishable from regular pits mechanically

~~Guard Patrols: Soldiers patrol designated areas and can be avoided or defeated.~~

~~Crumbling Watchtowers: Platforms collapse after the player crosses them.~~

River Crossing: Players must jump between moving boats to reach the opposite bank.

* Similar to floating driftwood

~~Special obstacle: Cannon Barrage — Multiple cannons fire in alternating patterns while the player crosses a fortified area.~~

### **Stage 3**

~~Fiber Bundles: Large bundles obstruct the path and require jumping.~~

* No assets

Rolling Carts: Move horizontally toward the player.

* Basically a reskin of rolling cannonballs

Falling Wooden Crates: Drop from storage platforms.

* Introduction of the falling objects for later

~~Tangled Fibers: Slow the player when stepped on.~~

* No assets. And doesn’t introduce meaningful decisions.

~~Plantation Irrigation: Ditches Gaps requiring accurate jumps.~~

* What does this mean?

~~Moving Farm Machinery: Rotating mechanisms require timed movement.~~

* No assets. And there are no other rotating things in the game

~~Unstable Wooden Walkways: Collapse after a short delay.~~

* No assets

~~Muddy Paths: Reduce traction and movement speed.~~

* Same problem as before of it not introducing many new decisions.

### **Stage 4**

Barbed Wire Fences: Must be jumped over or avoided.

Falling Building Debris: Rubble falls from damaged structures.

~~Exploding Shells: Marked ground areas explode after a warning.~~

* No available animation

~~Spotlights: Players must hide behind objects to avoid detection.~~ 

* Stealth mechanics are an entirely different game

~~Landmines: Hazardous tiles require careful navigation.~~

* No available animation

~~Collapsed Bridges: Require jumping across broken sections.~~

* No assets

~~Military Roadblocks: Block paths and require detours or destruction.~~

* There are no detours since this is a 2d linear game. And destruction mechanics are a new system entirely.

~~Enemy Patrols Soldiers follow patrol routes, requiring stealth or combat.~~

* Stealth and combat are new systems that need to be designed

~~Smoke Clouds Temporarily obscure the player's vision.~~

* The way this should be used is very unclear

Crumbling Trenches Players must jump over gaps in damaged defensive positions.

* Yes but only imply that they’re trenches

### **Stage 5**

Moving Cars: Vehicles cross the player's path at varying speeds.

* Slightly different from normal moving platforms since they can kill you

Road Construction Barriers: Require jumping or sliding.

* No sliding since that isn’t implemented and there are no animations

~~Falling Fruits: drop from trees and must be dodged.~~

* Doesn’t make much sense in a city?

Rolling Fruit Carts: Move across market pathways.	

* There’s no asset for this

Flooded Streets: Slow movement and may hide small hazards.

* Yes. But hiding hazards is bad design. Leads to frustration since the player cannot anticipate and prepare for them. Will think it’s a failure of the game and not a failure of their skill.

Open Drainage Canals: Require precise jumps.

* Yes since water already exists. But indistinguishable for regular pits really

~~Hanging Electrical Wires: Low obstacles requiring players to slide underneath.~~

* No sliding

Construction Debris: Falling materials create temporary hazards.

* Same assets as building debris from before

Market Crates: Stacked crates form climbing and jumping challenges.

~~Busy Intersections: Players must time crossings between moving vehicles.~~

* No such thing as intersections since this is a 2d platformer where vehicles can only move left and right.

~~Special obstacle: City Rush — A fast-paced section combining cars, construction barriers, and market carts, testing the player's timing and reaction speed.~~

* Dodging a single car is already a test of timing and reaction speed. One should be enough. Dodging cars should instead be the central mechanic of the level