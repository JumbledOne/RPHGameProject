extends CanvasLayer

# ((heart textures denize(sorry kung mali spell lol) and drake made) drag a heart image here in the Inspector. kung empty, red squares are used.
@export var heart_texture: Texture2D

func _ready() -> void:
	_ignore_mouse(self)
	GameState.hearts_changed.connect(_update_hearts)
	GameState.cacao_changed.connect(func(v): %CacaoLabel.text = "Cacao: %d" % v)
	GameState.score_changed.connect(func(v): %ScoreLabel.text = "Score: %d" % v)
	GameState.powerup_changed.connect(_show_powerup)

	_update_hearts(GameState.hearts)
	%CacaoLabel.text = "Cacao: %d" % GameState.cacao
	%ScoreLabel.text = "Score: %d" % GameState.score
	%PowerupLabel.text = ""
	%TimelineTitle.modulate.a = 0.0

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

func _show_powerup(powerup_name: String, duration: float) -> void:
	%PowerupLabel.text = powerup_name
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout
		%PowerupLabel.text = ""

# Big title in the middle for 3s, then shrinks and moves to the top middle.
func show_timeline_title() -> void:
	var info = GameState.LEVELS[GameState.selected_level]
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
