extends CanvasLayer

# ((heart textures denize(sorry kung mali spell lol) and drake made) drag a heart image here in the Inspector. kung empty, red squares are used.
@export var heart_texture: Texture2D

func _ready() -> void:
	_ignore_mouse(self)
	GameManager.player_set.connect(_on_player_set)
	LevelManager.cacao_changed.connect(func(v): %CacaoLabel.text = "Cacao: %d" % v)
	LevelManager.score_changed.connect(func(v): %ScoreLabel.text = "Score: %d" % v)

	_on_player_set()
	%CacaoLabel.text = "Cacao: %d" % LevelManager.cacao
	%ScoreLabel.text = "Score: %d" % LevelManager.score
	%PowerupLabel.text = ""
	%TimelineTitle.modulate.a = 0.0

func _on_player_set() -> void:
	var player := GameManager.player
	if not is_instance_valid(player):
		_update_hearts(0)
		return
	player.damaged.connect(_on_player_health_changed)
	player.healed.connect(_on_player_health_changed)
	_update_hearts(player.health)

func _on_player_health_changed() -> void:
	if is_instance_valid(GameManager.player):
		_update_hearts(GameManager.player.health)

# Makes every HUD control clickthrough so it never blocks buttons underneath.
func _ignore_mouse(node: Node) -> void:
	for c in node.get_children():
		if c is Control:
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse(c)

func _update_hearts(value: int) -> void:
	for c in %HeartsBox.get_children():
		c.queue_free()
	for i in value:
		if heart_texture:
			var h: TextureRect = TextureRect.new()
			h.mouse_filter = Control.MOUSE_FILTER_IGNORE
			h.texture = heart_texture
			h.custom_minimum_size = Vector2(32, 32)
			h.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			h.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			%HeartsBox.add_child(h)
		else:
			var r: ColorRect = ColorRect.new()
			r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			r.color = Color.RED
			r.custom_minimum_size = Vector2(28, 28)
			%HeartsBox.add_child(r)

# Big title in the middle for 3s, then shrinks and moves to the top middle.
func show_timeline_title() -> void:
	var info: Dictionary = LevelManager.get_level_info(LevelManager.selected_level)
	var title: Label = %TimelineTitle
	title.text = "%s - %s" % [info["date"], info["title"]]
	await get_tree().process_frame  # let the label compute its size
	var screen_h: float = get_viewport().get_visible_rect().size.y
	title.pivot_offset = title.size / 2
	title.scale = Vector2(1.6, 1.6)
	title.position.y = screen_h / 2.0 - title.size.y / 2.0
	title.modulate.a = 0.0

	var t: Tween = create_tween()
	t.tween_property(title, "modulate:a", 1.0, 0.5)      # fade in
	t.tween_interval(3.0)                                 # stay for 3 seconds
	t.tween_property(title, "scale", Vector2(0.8, 0.8), 0.6)   # then shrink...
	t.parallel().tween_property(title, "position:y", 56.0, 0.6) # ...and move up
