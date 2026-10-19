class_name EvilDurianMovementComponent
extends Component

var player_pos_when_jumping: Array = []
var target_pos: Vector2 = Vector2.ZERO
var is_connected_to_player: bool = false

func _ready() -> void:
	if GameManager.player:
		GameManager.player.jumped.connect(_on_player_jumped)

func _on_player_jumped():
	player_pos_when_jumping.append(GameManager.player.position)
	print("appended player jump pos")

func tick(enemy: Enemy_Entity, delta: float) -> void:
	
	
	
	if not is_connected_to_player and GameManager.player:
		if GameManager.player.has_signal("jumped"):
			GameManager.player.jumped.connect(_on_player_jumped)
			is_connected_to_player = true

	if not enemy.is_jumping and not enemy.is_jumping:
		if player_pos_when_jumping.is_empty():
			target_pos = GameManager.player.position
		else:
			target_pos = player_pos_when_jumping[0]
	
	if not enemy.is_jumping:
		if player_pos_when_jumping.is_empty():
			# FALLBACK: Just follow the live player (DO NOT trigger jumps here!)
			if GameManager.player:
				target_pos = GameManager.player.position
			else:
				target_pos = enemy.position
		else:
			# QUEUE HAS ITEMS: We are chasing a recorded jump!
			target_pos = player_pos_when_jumping[0]
			
			# Check arrival ONLY when chasing a recorded jump
			if abs(enemy.position.x - target_pos.x) < 5.0:
				enemy.velocity.x = 0
				enemy.start_jump()
				player_pos_when_jumping.pop_front()
				return
	
	var direction = enemy.position.direction_to(target_pos).x
	enemy.velocity.x = direction * enemy.speed
	
	if enemy.is_jumping:
		enemy.jump_timer -= delta
		enemy.velocity.y = enemy.jump_speed
		
		if enemy.jump_timer <= 0:
			enemy.is_jumping = false
	else:
		if not enemy.is_on_floor():
			enemy.velocity.y += 980.0 * delta
		else:
			enemy.velocity.y = 0.0
