class_name GildedThroneRoom
extends Stage

## The Gilded Throne Room — Don the Con's exclusive boss arena.
## Hazard: at 25% HP, FAKE NEWS banners drop and obscure ~20% of screen
## edges (visual obstruction only, no damage). Banners persist for the fight.


var _boss: Fighter = null
var _banners_spawned: bool = false


func _ready() -> void:
	stage_name = "The Gilded Throne Room"
	# No interval-based hazard — triggered by boss HP signal
	super._ready()


## Called by GameManager / arcade flow to wire up the boss fighter.
func set_boss(boss: Fighter) -> void:
	_boss = boss
	if is_instance_valid(_boss):
		_boss.health_changed.connect(_on_boss_health_changed)


func _on_boss_health_changed(new_health: float) -> void:
	if _banners_spawned:
		return
	if not is_instance_valid(_boss):
		return
	var threshold: float = _boss.max_health * 0.25
	if new_health <= threshold:
		_spawn_fake_news_banners()


func _spawn_fake_news_banners() -> void:
	_banners_spawned = true

	# Place banners on a high CanvasLayer so they render over all game content.
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	# Four banners covering ~20% of each screen edge (top, bottom, left, right).
	var screen := Vector2(1280.0, 720.0)
	var configs: Array = [
		# [rect position, rect size, label text]
		[Vector2(0.0, 0.0),              Vector2(screen.x, screen.y * 0.2), "FAKE NEWS"],
		[Vector2(0.0, screen.y * 0.8),  Vector2(screen.x, screen.y * 0.2), "FAKE NEWS"],
		[Vector2(0.0, 0.0),             Vector2(screen.x * 0.2, screen.y), "FAKE NEWS"],
		[Vector2(screen.x * 0.8, 0.0), Vector2(screen.x * 0.2, screen.y), "FAKE NEWS"],
	]

	for cfg in configs:
		var banner := _make_banner(cfg[0], cfg[1], cfg[2])
		canvas.add_child(banner)


func _make_banner(pos: Vector2, size: Vector2, text: String) -> Control:
	var rect := ColorRect.new()
	rect.position = pos
	rect.size = size
	rect.color = Color(0.85, 0.1, 0.1, 0.75)  # bold red, semi-opaque

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = size
	label.position = Vector2.ZERO

	rect.add_child(label)
	return rect
