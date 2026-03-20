# Plan 4: Stage System

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all 9 stages with unique hazards, visual descriptions, and the stage-fighter mapping for arcade mode.

**Architecture:** Each stage extends the Stage base class (updated in Plan 1 with hazard support). Each stage creates and registers its hazard(s) in `_ready()`. Hazards extend StageHazard and override `activate()`.

**Tech Stack:** Godot 4.2, GDScript

**Spec:** `docs/superpowers/specs/2026-03-20-character-and-stage-redesign.md`
**Depends on:** Plan 1 (Core Engine — StageHazard base class)

---

### File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `scripts/stages/supremely_cunty_court.gd` | Gavel shockwave hazard |
| Create | `scripts/stages/fili_buster_lounge.gd` | Bass drop launch hazard |
| Create | `scripts/stages/border_runway.gd` | Dazzle spotlight hazard |
| Create | `scripts/stages/pray_away_the_slay.gd` | Holy water slow hazard |
| Create | `scripts/stages/book_ban_bonfire.gd` | Book projectile + buff hazard |
| Create | `scripts/stages/mar_a_lardo.gd` | Document slip/stun hazard |
| Create | `scripts/stages/gerrymandered_gauntlet.gd` | Layout redraw hazard |
| Create | `scripts/stages/pride_float_of_war.gd` | Momentum shift hazard |
| Create | `scripts/stages/gilded_throne_room.gd` | Fake News visual obstruction |
| Create | `scripts/core/stage_registry.gd` | Maps stage names to scripts + fighter pairings |

---

### Task 1: Stage Registry

**Files:**
- Create: `scripts/core/stage_registry.gd`

- [ ] **Step 1: Create stage registry**

```gdscript
class_name StageRegistry
extends RefCounted

## Maps politicians to their home stages for arcade mode.

const STAGE_MAP = {
	"Ron DeSanctimonious": "book_ban_bonfire",
	"Marjorie Trailer Queen": "supremely_cunty_court",
	"Cancun Cruz": "border_runway",
	"Moscow Mitch": "fili_buster_lounge",
	"Elmo Musk": "gerrymandered_gauntlet",
	"Mike Dense": "pray_away_the_slay",
	"Greg Ablot": "mar_a_lardo",
	"Don the Con": "gilded_throne_room",
}

const STAGE_SCRIPTS = {
	"supremely_cunty_court": "res://scripts/stages/supremely_cunty_court.gd",
	"fili_buster_lounge": "res://scripts/stages/fili_buster_lounge.gd",
	"border_runway": "res://scripts/stages/border_runway.gd",
	"pray_away_the_slay": "res://scripts/stages/pray_away_the_slay.gd",
	"book_ban_bonfire": "res://scripts/stages/book_ban_bonfire.gd",
	"mar_a_lardo": "res://scripts/stages/mar_a_lardo.gd",
	"gerrymandered_gauntlet": "res://scripts/stages/gerrymandered_gauntlet.gd",
	"pride_float_of_war": "res://scripts/stages/pride_float_of_war.gd",
	"gilded_throne_room": "res://scripts/stages/gilded_throne_room.gd",
}

const VERSUS_ONLY_STAGES = ["pride_float_of_war"]

static func get_stage_for_fighter(fighter_name: String) -> String:
	return STAGE_MAP.get(fighter_name, "pride_float_of_war")

static func get_all_stage_names() -> Array:
	return STAGE_SCRIPTS.keys()
```

- [ ] **Step 2: Commit**

```bash
git add scripts/core/stage_registry.gd
git commit -m "feat: add StageRegistry — maps fighters to home stages"
```

---

### Task 2: The Supremely Cunty Court

**Files:**
- Create: `scripts/stages/supremely_cunty_court.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## The Supremely Cunty Court
## Drag brunch at the Supreme Court. Gavel shockwave every 20 seconds.


func _ready() -> void:
	stage_name = "The Supremely Cunty Court"
	super._ready()

	var hazard = GavelHazard.new()
	register_hazard(hazard)


class GavelHazard extends StageHazard:
	const SHOCKWAVE_DAMAGE: float = 5.0
	const LAUNCH_FORCE: float = 400.0

	func _init():
		interval = 20.0
		hazard_name = "Gavel Slam"

	func activate() -> void:
		# Shockwave hits everyone and launches them
		apply_damage_to_all(SHOCKWAVE_DAMAGE, false)
		apply_launch_to_all(LAUNCH_FORCE)
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/supremely_cunty_court.gd
git commit -m "feat: add The Supremely Cunty Court stage — gavel shockwave"
```

---

### Task 3: The Fili-Buster Lounge

**Files:**
- Create: `scripts/stages/fili_buster_lounge.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## The Fili-Buster Lounge
## Senate chamber nightclub. Bass drop every 30 seconds launches fighters.


func _ready() -> void:
	stage_name = "The Fili-Buster Lounge"
	super._ready()

	var hazard = BassDropHazard.new()
	register_hazard(hazard)


class BassDropHazard extends StageHazard:
	const LAUNCH_FORCE: float = 500.0

	func _init():
		interval = 30.0
		hazard_name = "Bass Drop"

	func activate() -> void:
		# No damage, just repositions via launch
		apply_launch_to_all(LAUNCH_FORCE)
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/fili_buster_lounge.gd
git commit -m "feat: add The Fili-Buster Lounge stage — bass drop launch"
```

---

### Task 4: The Border Runway

**Files:**
- Create: `scripts/stages/border_runway.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## The Border Runway
## Fashion runway on the border wall. Spotlight dazzle debuff.


func _ready() -> void:
	stage_name = "The Border Runway"
	super._ready()

	var hazard = SpotlightHazard.new()
	register_hazard(hazard)


class SpotlightHazard extends StageHazard:
	var _target_fighter: Fighter = null
	var _tracking_timer: float = 0.0
	const DAZZLE_THRESHOLD: float = 3.0
	const DAZZLE_DURATION: float = 4.0
	const WHIFF_CHANCE: float = 0.3

	func _init():
		interval = 10.0  # Re-target every 10 seconds
		hazard_name = "Spotlight"

	func activate() -> void:
		# Pick a random fighter to track
		if fighters.size() > 0:
			_target_fighter = fighters[randi() % fighters.size()]
			_tracking_timer = 0.0

	func _physics_process(delta: float) -> void:
		super._physics_process(delta)
		if _target_fighter:
			_tracking_timer += delta
			if _tracking_timer >= DAZZLE_THRESHOLD:
				# Apply dazzle debuff
				# TODO: Set a dazzle flag on the fighter that causes 30% whiff
				_tracking_timer = 0.0
				_target_fighter = null
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/border_runway.gd
git commit -m "feat: add The Border Runway stage — spotlight dazzle hazard"
```

---

### Task 5: Pray Away the Slay

**Files:**
- Create: `scripts/stages/pray_away_the_slay.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## Pray Away the Slay
## Megachurch ballroom. Holy water sprinklers slow fighters.


func _ready() -> void:
	stage_name = "Pray Away the Slay"
	super._ready()

	var hazard = HolyWaterHazard.new()
	register_hazard(hazard)


class HolyWaterHazard extends StageHazard:
	const SLOW_AMOUNT: float = 0.3  # 30% slow
	const SPRAY_DURATION: float = 5.0
	var _spray_active: bool = false
	var _spray_timer: float = 0.0

	func _init():
		interval = 25.0
		hazard_name = "Holy Water Sprinklers"

	func activate() -> void:
		_spray_active = true
		_spray_timer = SPRAY_DURATION

	func _physics_process(delta: float) -> void:
		super._physics_process(delta)
		if _spray_active:
			_spray_timer -= delta
			if _spray_timer <= 0:
				_spray_active = false
				# Restore speeds
				for fighter in fighters:
					# Speed is managed by the fighter's get_effective_speed()
					# TODO: Apply temporary slow modifier
					pass
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/pray_away_the_slay.gd
git commit -m "feat: add Pray Away the Slay stage — holy water slow hazard"
```

---

### Task 6: Book Ban Bonfire

**Files:**
- Create: `scripts/stages/book_ban_bonfire.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## Book Ban Bonfire
## Burning library. Book projectiles that buff on hit.


func _ready() -> void:
	stage_name = "Book Ban Bonfire"
	super._ready()

	var hazard = BookProjectileHazard.new()
	register_hazard(hazard)


class BookProjectileHazard extends StageHazard:
	const BOOK_DAMAGE: float = 3.0
	const BUFF_DURATION: float = 8.0
	const BUFF_DAMAGE_BONUS: float = 0.1  # +10% damage

	func _init():
		interval = 10.0
		hazard_name = "Banned Book Barrage"

	func activate() -> void:
		# Fire a book projectile across the stage
		var proj = Projectile.new()
		proj.damage = BOOK_DAMAGE
		proj.speed = 300.0
		proj.direction = [-1.0, 1.0][randi() % 2]
		proj.unblockable = false
		proj.lifetime = 5.0
		# Book projectile spawns from a random side
		if proj.direction > 0:
			proj.position = Vector2(-20, 400 + randf() * 150)
		else:
			proj.position = Vector2(1300, 400 + randf() * 150)
		# TODO: On hit, grant +10% damage buff for 8 seconds
		get_parent().add_child(proj)
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/book_ban_bonfire.gd
git commit -m "feat: add Book Ban Bonfire stage — book projectile buff hazard"
```

---

### Task 7: Mar-a-Lardo's Dinner Theatre

**Files:**
- Create: `scripts/stages/mar_a_lardo.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## Mar-a-Lardo's Dinner Theatre
## Gold-plated ballroom. Classified documents cause stun on step.


func _ready() -> void:
	stage_name = "Mar-a-Lardo's Dinner Theatre"
	super._ready()

	var hazard = DocumentHazard.new()
	register_hazard(hazard)


class DocumentHazard extends StageHazard:
	const STUN_DURATION: float = 1.0

	func _init():
		interval = 15.0
		hazard_name = "Classified Documents"

	func activate() -> void:
		# Spawn a document on the ground at a random position
		var doc = Area2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(40, 10)
		var collision = CollisionShape2D.new()
		collision.shape = shape
		doc.add_child(collision)
		doc.position = Vector2(200 + randf() * 880, 615)  # On the floor

		doc.body_entered.connect(func(body):
			if body is Fighter:
				# Stun: set speed to 0 briefly
				var original_speed = body.speed
				body.speed = 0.0
				body.velocity = Vector2.ZERO
				await get_tree().create_timer(STUN_DURATION).timeout
				body.speed = original_speed
				doc.queue_free()
		)

		get_parent().add_child(doc)
		# Auto-remove after 10 seconds if not triggered
		await get_tree().create_timer(10.0).timeout
		if is_instance_valid(doc):
			doc.queue_free()
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/mar_a_lardo.gd
git commit -m "feat: add Mar-a-Lardo's Dinner Theatre stage — document stun hazard"
```

---

### Task 8: Gerrymandered Gauntlet

**Files:**
- Create: `scripts/stages/gerrymandered_gauntlet.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## Gerrymandered Gauntlet
## Stage layout redraws every 20 seconds from 5 predefined layouts.

var _current_layout: int = 0
var _platforms: Array[StaticBody2D] = []

# 5 predefined layouts — each is an array of platform Rect2 (position + size)
const LAYOUTS = [
	[],  # Layout 0: flat, no platforms
	[Vector2(300, 500), Vector2(900, 500)],  # Layout 1: two platforms
	[Vector2(640, 450)],  # Layout 2: one center platform
	[Vector2(200, 520), Vector2(640, 400), Vector2(1080, 520)],  # Layout 3: three tiered
	[Vector2(400, 480), Vector2(880, 480)],  # Layout 4: two wide platforms
]
const PLATFORM_SIZE = Vector2(160, 15)


func _ready() -> void:
	stage_name = "Gerrymandered Gauntlet"
	super._ready()

	var hazard = RedrawHazard.new()
	hazard.stage_ref = self
	register_hazard(hazard)
	_apply_layout(0)


func _apply_layout(index: int) -> void:
	# Clear existing platforms
	for plat in _platforms:
		plat.queue_free()
	_platforms.clear()

	_current_layout = index
	var layout = LAYOUTS[index]

	for plat_pos in layout:
		var plat = StaticBody2D.new()
		var shape = RectangleShape2D.new()
		shape.size = PLATFORM_SIZE
		var collision = CollisionShape2D.new()
		collision.shape = shape
		plat.add_child(collision)
		plat.position = plat_pos
		add_child(plat)
		_platforms.append(plat)


func redraw() -> void:
	var new_layout = randi() % LAYOUTS.size()
	while new_layout == _current_layout:
		new_layout = randi() % LAYOUTS.size()

	# Push fighters to safe ground before redraw
	for fighter in hazards[0].fighters:
		if not fighter.is_on_floor():
			fighter.velocity.y = 200.0  # Push down

	_apply_layout(new_layout)


class RedrawHazard extends StageHazard:
	var stage_ref = null  # Reference to parent stage

	func _init():
		interval = 20.0
		hazard_name = "Gerrymander Redraw"

	func activate() -> void:
		if stage_ref:
			# 1-second warning flash
			# TODO: Visual flash warning
			await get_tree().create_timer(1.0).timeout
			stage_ref.redraw()
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/gerrymandered_gauntlet.gd
git commit -m "feat: add Gerrymandered Gauntlet stage — platform layout redraw"
```

---

### Task 9: Pride Float of War

**Files:**
- Create: `scripts/stages/pride_float_of_war.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## Pride Float of War
## Moving parade float. Momentum pushes fighters every 15 seconds.


func _ready() -> void:
	stage_name = "Pride Float of War"
	super._ready()

	var hazard = MomentumShiftHazard.new()
	register_hazard(hazard)


class MomentumShiftHazard extends StageHazard:
	const PUSH_FORCE: float = 100.0  # pixels
	const PUSH_DURATION: float = 2.0
	var _pushing: bool = false
	var _push_timer: float = 0.0
	var _push_direction: float = 1.0

	func _init():
		interval = 15.0
		hazard_name = "Float Turn"

	func activate() -> void:
		_pushing = true
		_push_timer = PUSH_DURATION
		_push_direction = [-1.0, 1.0][randi() % 2]

	func _physics_process(delta: float) -> void:
		super._physics_process(delta)
		if _pushing:
			_push_timer -= delta
			var force_per_frame = (PUSH_FORCE / PUSH_DURATION) * delta
			for fighter in fighters:
				fighter.velocity.x += _push_direction * force_per_frame
			if _push_timer <= 0:
				_pushing = false
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/pride_float_of_war.gd
git commit -m "feat: add Pride Float of War stage — momentum shift hazard"
```

---

### Task 10: The Gilded Throne Room (Boss Stage)

**Files:**
- Create: `scripts/stages/gilded_throne_room.gd`

- [ ] **Step 1: Create stage script**

```gdscript
extends Stage

## The Gilded Throne Room — Don the Con's exclusive boss stage.
## Hazard: At 25% HP, FAKE NEWS banners obscure 20% of screen.

var _fake_news_triggered: bool = false
var _boss_ref: Fighter = null


func _ready() -> void:
	stage_name = "The Gilded Throne Room"
	super._ready()


func set_boss(boss: Fighter) -> void:
	_boss_ref = boss
	# Monitor boss health for FAKE NEWS trigger
	boss.health_changed.connect(_on_boss_health_changed)


func _on_boss_health_changed(new_health: float) -> void:
	if _fake_news_triggered or not _boss_ref:
		return
	if new_health <= _boss_ref.max_health * 0.25:
		_trigger_fake_news()


func _trigger_fake_news() -> void:
	_fake_news_triggered = true
	# Spawn visual obstruction banners
	# These are ColorRect nodes that block portions of the screen
	var banner_positions = [
		Rect2(0, 0, 256, 720),      # Left 20%
		# Alternative positions chosen randomly:
		# Rect2(1024, 0, 256, 720),  # Right 20%
		# Rect2(0, 0, 1280, 144),    # Top 20%
	]
	var chosen = banner_positions[randi() % banner_positions.size()]

	var banner = ColorRect.new()
	banner.color = Color(0.8, 0.1, 0.1, 0.7)
	banner.position = chosen.position
	banner.size = chosen.size

	var label = Label.new()
	label.text = "FAKE NEWS"
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = chosen.size
	banner.add_child(label)

	# Add to a CanvasLayer so it's always on top
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	canvas.add_child(banner)
	add_child(canvas)
```

- [ ] **Step 2: Commit**

```bash
git add scripts/stages/gilded_throne_room.gd
git commit -m "feat: add The Gilded Throne Room — boss stage with FAKE NEWS hazard"
```
