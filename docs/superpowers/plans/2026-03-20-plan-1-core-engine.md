# Plan 1: Core Engine Systems

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the Fighter base class and core systems to support all mechanics needed by the new roster — passives, stat modifiers, input remapping, knockback, taunting, projectiles, and round reset.

**Architecture:** Extend the existing Fighter base class with new systems layered on top. Input remapping sits between raw Input and handle_input(). Stat modifiers are a dictionary on each fighter. Projectiles are their own scene/script. All new systems are opt-in — fighters that don't use a system simply don't call it.

**Tech Stack:** Godot 4.2, GDScript

**Spec:** `docs/superpowers/specs/2026-03-20-character-and-stage-redesign.md`

---

### File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Modify | `scripts/core/fighter.gd` | Add passive_proc(), stat modifiers, knockback, taunt, round reset, secondary resource hooks |
| Modify | `scripts/core/game_manager.gd` | Register as autoload, add round reset broadcast, arcade mode state |
| Modify | `scripts/core/stage.gd` | Add hazard system hooks |
| Modify | `scripts/ui/hud.gd` | Add secondary meter display, debuff indicators |
| Modify | `project.godot` | Add taunt input mapping, register GameManager autoload |
| Create | `scripts/core/input_manager.gd` | Input remapping layer — intercepts inputs, applies scrambles/bans/silences |
| Create | `scripts/core/projectile.gd` | Base projectile class — travels, hits, applies damage |
| Create | `scripts/core/burning_zone.gd` | Ground zone that deals DOT to fighters standing in it |
| Create | `scripts/core/stage_hazard.gd` | Base stage hazard class with timer and effect method |
| Create | `tests/test_stat_modifiers.gd` | GUT test for stat modifier math |
| Create | `tests/test_damage_formula.gd` | GUT test for damage formula |
| Create | `tests/test_input_manager.gd` | GUT test for input remapping |

---

### Task 1: Set Up GUT Testing Framework

**Files:**
- Modify: `project.godot`
- Create: `tests/test_runner.tscn`

- [ ] **Step 1: Install GUT addon**

```bash
cd /Users/mvacirca/dev/sashay-and-slay
mkdir -p addons
git clone https://github.com/bitwes/Gut.git addons/gut --depth 1
```

- [ ] **Step 2: Create test runner scene**

Create `tests/test_runner.tscn` — a minimal scene with GUT's test runner node. We'll run tests via command line.

- [ ] **Step 3: Verify GUT loads**

```bash
# From project root, open in Godot and verify no errors
# Or run headless if available:
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

- [ ] **Step 4: Commit**

```bash
git add addons/gut tests/
git commit -m "chore: add GUT testing framework"
```

---

### Task 2: Upgrade Fighter Base Class — Stat Modifier System

**Files:**
- Modify: `scripts/core/fighter.gd`
- Create: `tests/test_stat_modifiers.gd`

- [ ] **Step 1: Write the failing test**

Create `tests/test_stat_modifiers.gd`:

```gdscript
extends GutTest

var fighter: Fighter

func before_each():
	fighter = Fighter.new()
	fighter.max_health = 100.0
	fighter.punch_damage = 10.0
	fighter.kick_damage = 12.0
	fighter.speed = 300.0
	add_child(fighter)

func after_each():
	fighter.queue_free()

func test_initial_stat_modifier_is_1():
	assert_eq(fighter.get_stat_modifier(), 1.0)

func test_apply_stat_reduction():
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.9, 0.01)

func test_stat_reduction_stacks():
	fighter.apply_stat_reduction()
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.8, 0.01)

func test_stat_reduction_min_is_half():
	for i in range(10):
		fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.5, 0.01)

func test_reset_stat_modifiers():
	fighter.apply_stat_reduction()
	fighter.apply_stat_reduction()
	fighter.reset_round_state()
	assert_eq(fighter.get_stat_modifier(), 1.0)

func test_effective_punch_damage():
	fighter.apply_stat_reduction()  # 0.9x
	assert_almost_eq(fighter.get_effective_punch(), 9.0, 0.01)

func test_effective_kick_damage():
	fighter.apply_stat_reduction()  # 0.9x
	assert_almost_eq(fighter.get_effective_kick(), 10.8, 0.01)
```

- [ ] **Step 2: Run test to verify it fails**

```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gtest=test_stat_modifiers.gd -gexit
```
Expected: FAIL — methods don't exist yet.

- [ ] **Step 3: Add stat modifier system to Fighter**

In `scripts/core/fighter.gd`, add these properties after the existing vars:

```gdscript
# Stat modifier system
var _stat_reduction_count: int = 0
const STAT_REDUCTION_PER_STACK: float = 0.1
const STAT_REDUCTION_MIN: float = 0.5
```

Add these methods after `get_catchphrase()`:

```gdscript
func get_stat_modifier() -> float:
	return max(1.0 - _stat_reduction_count * STAT_REDUCTION_PER_STACK, STAT_REDUCTION_MIN)

func apply_stat_reduction() -> void:
	_stat_reduction_count += 1

func get_effective_punch() -> float:
	return punch_damage * get_stat_modifier()

func get_effective_kick() -> float:
	return kick_damage * get_stat_modifier()

func get_effective_speed() -> float:
	return speed * get_stat_modifier()

func reset_round_state() -> void:
	_stat_reduction_count = 0
	special_meter = 0.0
	is_blocking = false
	is_attacking = false
```

- [ ] **Step 4: Update take_damage() to use stat modifiers**

In `scripts/core/fighter.gd`, update `attack()` to use effective stats:

```gdscript
# In handle_input(), replace punch/kick damage references:
if Input.is_action_just_pressed(prefix + "punch"):
    attack("punch", get_effective_punch())
elif Input.is_action_just_pressed(prefix + "kick"):
    attack("kick", get_effective_kick())
```

And update movement to use effective speed:

```gdscript
# In handle_input():
velocity.x = direction * get_effective_speed()
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gtest=test_stat_modifiers.gd -gexit
```
Expected: All PASS

- [ ] **Step 6: Commit**

```bash
git add scripts/core/fighter.gd tests/test_stat_modifiers.gd
git commit -m "feat: add stat modifier system to Fighter base class"
```

---

### Task 3: Damage Formula and Knockback

**Files:**
- Modify: `scripts/core/fighter.gd`
- Create: `tests/test_damage_formula.gd`

- [ ] **Step 1: Write the failing test**

Create `tests/test_damage_formula.gd`:

```gdscript
extends GutTest

var attacker: Fighter
var defender: Fighter

func before_each():
	attacker = Fighter.new()
	attacker.punch_damage = 10.0
	attacker.kick_damage = 12.0
	defender = Fighter.new()
	defender.max_health = 100.0
	add_child(attacker)
	add_child(defender)
	defender._ready()

func after_each():
	attacker.queue_free()
	defender.queue_free()

func test_normal_damage():
	defender.take_damage(10.0, false)  # not blocked
	assert_eq(defender.health, 90.0)

func test_blocked_damage():
	defender.is_blocking = true
	defender.take_damage(10.0, false)  # blockable
	assert_eq(defender.health, 98.0)  # 10 * 0.2 = 2

func test_unblockable_ignores_block():
	defender.is_blocking = true
	defender.take_damage(10.0, true)  # unblockable
	assert_eq(defender.health, 90.0)

func test_knockback_modifier_high_hp():
	defender.max_health = 140.0  # Moscow Mitch
	var kb = defender.get_knockback_modifier()
	assert_almost_eq(kb, 100.0 / 140.0, 0.01)

func test_knockback_modifier_low_hp():
	defender.max_health = 90.0  # Anita Riot
	var kb = defender.get_knockback_modifier()
	assert_almost_eq(kb, 100.0 / 90.0, 0.01)

func test_special_meter_builds_on_damage_taken():
	defender.special_meter = 0.0
	defender.take_damage(20.0, false)
	assert_almost_eq(defender.special_meter, 10.0, 0.01)  # 20 * 0.5

func test_special_meter_caps_at_100():
	defender.special_meter = 95.0
	defender.take_damage(100.0, false)
	assert_eq(defender.special_meter, 100.0)
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — `take_damage()` signature has changed.

- [ ] **Step 3: Update take_damage() with new formula**

In `scripts/core/fighter.gd`, replace the existing `take_damage()`:

```gdscript
func take_damage(amount: float, unblockable: bool = false) -> void:
	var final_amount = amount
	if is_blocking and not unblockable:
		final_amount *= 0.2  # Block reduces damage by 80%

	health -= final_amount
	health = max(health, 0.0)
	health_changed.emit(health)

	# Build special meter when taking damage
	special_meter = min(special_meter + final_amount * 0.5, 100.0)
	special_meter_changed.emit(special_meter)

	if health <= 0:
		defeated.emit()

func get_knockback_modifier() -> float:
	return 100.0 / max_health

func apply_knockback(direction: float, force: float) -> void:
	var kb = get_knockback_modifier()
	velocity.x += direction * force * kb
```

- [ ] **Step 4: Add damage_dealt meter build to attack()**

Add a signal and meter build when damage is dealt. In `scripts/core/fighter.gd`:

```gdscript
signal damage_dealt(amount: float)

func on_damage_dealt(amount: float) -> void:
	special_meter = min(special_meter + amount * 0.4, 100.0)
	special_meter_changed.emit(special_meter)
```

- [ ] **Step 5: Run tests**

Expected: All PASS

- [ ] **Step 6: Commit**

```bash
git add scripts/core/fighter.gd tests/test_damage_formula.gd
git commit -m "feat: add damage formula with block/unblockable, knockback system"
```

---

### Task 4: Input Manager — Remapping Layer

**Files:**
- Create: `scripts/core/input_manager.gd`
- Create: `tests/test_input_manager.gd`
- Modify: `scripts/core/fighter.gd`
- Modify: `project.godot`

- [ ] **Step 1: Write the failing test**

Create `tests/test_input_manager.gd`:

```gdscript
extends GutTest

var input_mgr: InputManager

func before_each():
	input_mgr = InputManager.new()
	add_child(input_mgr)

func after_each():
	input_mgr.queue_free()

func test_normal_input_passthrough():
	assert_eq(input_mgr.get_remapped_action("p1_punch", true), "p1_punch")

func test_scramble_remaps_input():
	input_mgr.scramble_input("p1_", "punch", "kick", 3.0)
	assert_eq(input_mgr.get_remapped_action("p1_punch", true), "p1_kick")

func test_ban_blocks_input():
	input_mgr.ban_input("p1_", "punch", 15.0)
	assert_true(input_mgr.is_input_banned("p1_punch"))

func test_silence_blocks_all():
	input_mgr.silence_player("p1_", 4.0)
	assert_true(input_mgr.is_input_banned("p1_punch"))
	assert_true(input_mgr.is_input_banned("p1_kick"))
	assert_true(input_mgr.is_input_banned("p1_special"))
	assert_true(input_mgr.is_input_banned("p1_down"))  # block

func test_clear_all_effects():
	input_mgr.scramble_input("p1_", "punch", "kick", 3.0)
	input_mgr.ban_input("p1_", "kick", 15.0)
	input_mgr.clear_all("p1_")
	assert_eq(input_mgr.get_remapped_action("p1_punch", true), "p1_punch")
	assert_false(input_mgr.is_input_banned("p1_kick"))
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — InputManager class doesn't exist.

- [ ] **Step 3: Implement InputManager**

Create `scripts/core/input_manager.gd`:

```gdscript
class_name InputManager
extends Node

## Manages input remapping effects (scrambles, bans, silences).
## Sits between raw Input and fighter.handle_input().

# Active scrambles: { "p1_punch": { "target": "p1_kick", "expires": 12345.0 } }
var _scrambles: Dictionary = {}

# Active bans: { "p1_punch": expires_time }
var _bans: Dictionary = {}

# Active silences: { "p1_": expires_time }
var _silences: Dictionary = {}


func _process(_delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	_expire_effects(now)


func scramble_input(prefix: String, from_action: String, to_action: String, duration: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	var key = prefix + from_action
	_scrambles[key] = { "target": prefix + to_action, "expires": now + duration }


func ban_input(prefix: String, action: String, duration: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	_bans[prefix + action] = now + duration


func silence_player(prefix: String, duration: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	_silences[prefix] = now + duration


func get_remapped_action(action: String, _pressed: bool) -> String:
	if action in _scrambles:
		return _scrambles[action]["target"]
	return action


func is_input_banned(action: String) -> bool:
	# Check direct bans
	if action in _bans:
		return true
	# Check silences (match by prefix)
	for prefix in _silences:
		if action.begins_with(prefix):
			return true
	return false


func get_active_ban_count(prefix: String) -> int:
	var count = 0
	for key in _bans:
		if key.begins_with(prefix):
			count += 1
	return count


func clear_all(prefix: String) -> void:
	var keys_to_remove = []
	for key in _scrambles:
		if key.begins_with(prefix):
			keys_to_remove.append(key)
	for key in keys_to_remove:
		_scrambles.erase(key)

	keys_to_remove.clear()
	for key in _bans:
		if key.begins_with(prefix):
			keys_to_remove.append(key)
	for key in keys_to_remove:
		_bans.erase(key)

	_silences.erase(prefix)


func _expire_effects(now: float) -> void:
	var expired = []
	for key in _scrambles:
		if _scrambles[key]["expires"] <= now:
			expired.append(key)
	for key in expired:
		_scrambles.erase(key)

	expired.clear()
	for key in _bans:
		if _bans[key] <= now:
			expired.append(key)
	for key in expired:
		_bans.erase(key)

	expired.clear()
	for key in _silences:
		if _silences[key] <= now:
			expired.append(key)
	for key in expired:
		_silences.erase(key)
```

- [ ] **Step 4: Integrate InputManager into Fighter.handle_input()**

In `scripts/core/fighter.gd`, add a reference and use it:

```gdscript
# Add near top of fighter.gd:
var input_manager: InputManager = null

# Update handle_input() to check bans and remapping:
func handle_input(prefix: String) -> void:
	if is_attacking:
		return

	# Check for silence/global ban
	if input_manager and input_manager.is_input_banned(prefix + "left"):
		velocity.x = 0
		return

	var direction := Input.get_axis(prefix + "left", prefix + "right")
	velocity.x = direction * get_effective_speed()

	if direction != 0:
		facing_right = direction > 0

	if Input.is_action_just_pressed(prefix + "up") and is_on_floor():
		velocity.y = jump_force

	is_blocking = Input.is_action_pressed(prefix + "down") and is_on_floor()
	if input_manager and input_manager.is_input_banned(prefix + "down"):
		is_blocking = false

	var punch_action = prefix + "punch"
	var kick_action = prefix + "kick"
	if input_manager:
		punch_action = input_manager.get_remapped_action(punch_action, true)
		kick_action = input_manager.get_remapped_action(kick_action, true)

	if Input.is_action_just_pressed(punch_action) and not (input_manager and input_manager.is_input_banned(prefix + "punch")):
		attack("punch", get_effective_punch())
	elif Input.is_action_just_pressed(kick_action) and not (input_manager and input_manager.is_input_banned(prefix + "kick")):
		attack("kick", get_effective_kick())
	elif Input.is_action_just_pressed(prefix + "special") and special_meter >= 100.0 and not (input_manager and input_manager.is_input_banned(prefix + "special")):
		use_special()
```

- [ ] **Step 5: Run tests**

Expected: All PASS

- [ ] **Step 6: Commit**

```bash
git add scripts/core/input_manager.gd tests/test_input_manager.gd scripts/core/fighter.gd
git commit -m "feat: add InputManager for input remapping, bans, and silences"
```

---

### Task 5: Passive System and Taunt

**Files:**
- Modify: `scripts/core/fighter.gd`
- Modify: `project.godot`

- [ ] **Step 1: Add taunt input to project.godot**

Add these input actions to `project.godot` under `[input]`:

```
p1_taunt={...}  # Map to key "T"
p2_taunt={...}  # Map to key "Numpad 0"
```

This can also be done via Godot editor: Project > Project Settings > Input Map.

- [ ] **Step 2: Add passive and taunt to Fighter base class**

In `scripts/core/fighter.gd`, add:

```gdscript
# Properties
var is_taunting: bool = false
var taunt_duration: float = 1.0  # seconds, overridable
var _taunt_timer: float = 0.0
var opponent: Fighter = null  # Set by fight scene
var _hit_counter: int = 0  # Track hits landed (for passives like Anita's)

# Signals
signal taunt_started()
signal taunt_finished()
signal passive_triggered(passive_name: String)
```

Add to `_physics_process()`:

```gdscript
# After move_and_slide():
passive_proc(delta)
_process_taunt(delta)
```

Add methods:

```gdscript
func passive_proc(_delta: float) -> void:
	# Override in subclasses for character-specific passives
	pass

func use_special() -> void:
	# Override in subclasses for character-specific specials
	attack("special", special_damage)
	special_meter = 0.0
	special_meter_changed.emit(special_meter)

func start_taunt() -> void:
	if is_attacking or is_taunting:
		return
	is_taunting = true
	_taunt_timer = taunt_duration
	taunt_started.emit()

func _process_taunt(delta: float) -> void:
	if not is_taunting:
		return
	_taunt_timer -= delta
	if _taunt_timer <= 0:
		is_taunting = false
		taunt_finished.emit()
		on_taunt_complete()

func on_taunt_complete() -> void:
	# Override in subclasses for taunt effects
	pass

func on_hit_landed() -> void:
	_hit_counter += 1
```

Add taunt check in `handle_input()`:

```gdscript
# After special check:
if Input.is_action_just_pressed(prefix + "taunt") and not (input_manager and input_manager.is_input_banned(prefix + "taunt")):
    start_taunt()
```

- [ ] **Step 3: Add secondary resource hooks**

```gdscript
# In fighter.gd:
var secondary_resource: float = 0.0
var secondary_resource_max: float = 100.0
signal secondary_resource_changed(new_value: float)

func set_secondary_resource(value: float) -> void:
	secondary_resource = clamp(value, 0.0, secondary_resource_max)
	secondary_resource_changed.emit(secondary_resource)
```

- [ ] **Step 4: Add reset_round_state() comprehensive reset**

Update `reset_round_state()` to include all new systems:

```gdscript
func reset_round_state() -> void:
	_stat_reduction_count = 0
	special_meter = 0.0
	secondary_resource = 0.0
	is_blocking = false
	is_attacking = false
	is_taunting = false
	_taunt_timer = 0.0
	_hit_counter = 0
	health = max_health
	if input_manager:
		var prefix = "p1_" if is_player_one else "p2_"
		input_manager.clear_all(prefix)
```

- [ ] **Step 5: Commit**

```bash
git add scripts/core/fighter.gd project.godot
git commit -m "feat: add passive system, taunt, secondary resources to Fighter"
```

---

### Task 6: Projectile System

**Files:**
- Create: `scripts/core/projectile.gd`
- Create: `scripts/core/burning_zone.gd`

- [ ] **Step 1: Create Projectile base class**

Create `scripts/core/projectile.gd`:

```gdscript
class_name Projectile
extends Area2D

## Base projectile class. Travels in a direction, hits fighters, applies damage.

@export var speed: float = 400.0  # pixels/second
@export var damage: float = 10.0
@export var unblockable: bool = false
@export var direction: float = 1.0  # 1.0 = right, -1.0 = left
@export var lifetime: float = 3.0  # auto-destroy after this many seconds

var owner_fighter: Fighter = null  # Who shot this — won't hit them
var _lifetime_timer: float = 0.0


func _ready() -> void:
	# Connect to body_entered for hitting fighters
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	_lifetime_timer += delta
	if _lifetime_timer >= lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Fighter and body != owner_fighter:
		body.take_damage(damage, unblockable)
		if owner_fighter:
			owner_fighter.on_damage_dealt(damage)
		on_hit(body)
		queue_free()


func on_hit(_target: Fighter) -> void:
	# Override for special effects on hit (e.g., input banning)
	pass
```

- [ ] **Step 2: Create BurningZone**

Create `scripts/core/burning_zone.gd`:

```gdscript
class_name BurningZone
extends Area2D

## Ground zone that deals DOT to fighters standing in it.

@export var damage_per_second: float = 3.0
@export var duration: float = 8.0
@export var zone_width: float = 100.0

var _timer: float = 0.0
var _dot_timer: float = 0.0
var owner_fighter: Fighter = null  # Optional — some zones hurt everyone


func _ready() -> void:
	# Set up collision shape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(zone_width, 20)
	var collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func _physics_process(delta: float) -> void:
	_timer += delta
	_dot_timer += delta

	if _timer >= duration:
		queue_free()
		return

	# Apply damage every second
	if _dot_timer >= 1.0:
		_dot_timer -= 1.0
		for body in get_overlapping_bodies():
			if body is Fighter:
				if owner_fighter == null or body != owner_fighter:
					body.take_damage(damage_per_second, false)


func set_hurts_everyone(hurts_all: bool) -> void:
	if hurts_all:
		owner_fighter = null
```

- [ ] **Step 3: Add spawn helpers to Fighter**

In `scripts/core/fighter.gd`, add:

```gdscript
func spawn_projectile(proj_damage: float, proj_speed: float = 400.0, is_unblockable: bool = false) -> Projectile:
	var proj = Projectile.new()
	proj.damage = proj_damage
	proj.speed = proj_speed
	proj.unblockable = is_unblockable
	proj.direction = 1.0 if facing_right else -1.0
	proj.owner_fighter = self
	proj.position = global_position + Vector2(50.0 * proj.direction, -30.0)
	get_parent().add_child(proj)
	return proj

func spawn_burning_zone(zone_damage: float, zone_duration: float, zone_width: float = 100.0) -> BurningZone:
	var zone = BurningZone.new()
	zone.damage_per_second = zone_damage
	zone.duration = zone_duration
	zone.zone_width = zone_width
	zone.owner_fighter = self
	zone.position = global_position + Vector2(0, 10)
	get_parent().add_child(zone)
	return zone
```

- [ ] **Step 4: Commit**

```bash
git add scripts/core/projectile.gd scripts/core/burning_zone.gd scripts/core/fighter.gd
git commit -m "feat: add Projectile and BurningZone systems"
```

---

### Task 7: Stage Hazard Base Class

**Files:**
- Create: `scripts/core/stage_hazard.gd`
- Modify: `scripts/core/stage.gd`

- [ ] **Step 1: Create StageHazard base class**

Create `scripts/core/stage_hazard.gd`:

```gdscript
class_name StageHazard
extends Node2D

## Base class for all stage hazards. Triggers on a timer and applies effects.

@export var interval: float = 20.0  # Seconds between activations
@export var hazard_name: String = "Hazard"

var _timer: float = 0.0
var fighters: Array[Fighter] = []
var active: bool = true


func _physics_process(delta: float) -> void:
	if not active:
		return
	_timer += delta
	if _timer >= interval:
		_timer = 0.0
		activate()


func activate() -> void:
	# Override in subclasses
	pass


func get_fighters_in_area(area: Area2D) -> Array[Fighter]:
	var result: Array[Fighter] = []
	for body in area.get_overlapping_bodies():
		if body is Fighter:
			result.append(body)
	return result


func apply_damage_to_all(damage: float, unblockable: bool = false) -> void:
	for fighter in fighters:
		fighter.take_damage(damage, unblockable)


func apply_launch_to_all(force: float) -> void:
	for fighter in fighters:
		fighter.velocity.y = -force
```

- [ ] **Step 2: Update Stage base class**

In `scripts/core/stage.gd`, add hazard support:

```gdscript
# Add to stage.gd:
var hazards: Array[StageHazard] = []

func register_hazard(hazard: StageHazard) -> void:
	hazards.append(hazard)
	add_child(hazard)

func set_fighters(fighter_list: Array[Fighter]) -> void:
	for hazard in hazards:
		hazard.fighters = fighter_list

func deactivate_hazards() -> void:
	for hazard in hazards:
		hazard.active = false

func activate_hazards() -> void:
	for hazard in hazards:
		hazard.active = true
```

- [ ] **Step 3: Commit**

```bash
git add scripts/core/stage_hazard.gd scripts/core/stage.gd
git commit -m "feat: add StageHazard base class and hazard management to Stage"
```

---

### Task 8: HUD Updates for Secondary Meters

**Files:**
- Modify: `scripts/ui/hud.gd`

- [ ] **Step 1: Add secondary meter support to HUD**

In `scripts/ui/hud.gd`, add:

```gdscript
# New UI references (add to @onready section or get via path)
var p1_secondary_bar: ProgressBar = null
var p2_secondary_bar: ProgressBar = null
var p1_debuff_label: Label = null
var p2_debuff_label: Label = null

func setup_secondary_meter(player: int, meter_name: String, max_value: float) -> void:
	var bar = ProgressBar.new()
	bar.max_value = max_value
	bar.value = 0
	bar.custom_minimum_size = Vector2(200, 15)
	if player == 1:
		bar.position = Vector2(20, 80)
		p1_secondary_bar = bar
	else:
		bar.position = Vector2(1060, 80)
		p2_secondary_bar = bar
	add_child(bar)

func update_secondary(player: int, value: float) -> void:
	if player == 1 and p1_secondary_bar:
		p1_secondary_bar.value = value
	elif player == 2 and p2_secondary_bar:
		p2_secondary_bar.value = value

func show_debuff(player: int, text: String) -> void:
	# Show debuff indicator near the player's health bar
	var label = p1_debuff_label if player == 1 else p2_debuff_label
	if label == null:
		label = Label.new()
		label.add_theme_font_size_override("font_size", 12)
		if player == 1:
			label.position = Vector2(20, 95)
			p1_debuff_label = label
		else:
			label.position = Vector2(1060, 95)
			p2_debuff_label = label
		add_child(label)
	label.text = text

func clear_debuffs(player: int) -> void:
	if player == 1 and p1_debuff_label:
		p1_debuff_label.text = ""
	elif player == 2 and p2_debuff_label:
		p2_debuff_label.text = ""
```

- [ ] **Step 2: Commit**

```bash
git add scripts/ui/hud.gd
git commit -m "feat: add secondary meter and debuff indicator support to HUD"
```

---

### Task 9: GameManager — Round Reset Broadcast and Autoload

**Files:**
- Modify: `scripts/core/game_manager.gd`
- Modify: `project.godot`

- [ ] **Step 1: Register GameManager as autoload**

In `project.godot`, add under `[autoload]`:

```
GameManager="*res://scripts/core/game_manager.gd"
```

- [ ] **Step 2: Add round reset broadcast**

In `scripts/core/game_manager.gd`, add:

```gdscript
signal round_reset()

var fighters: Array[Fighter] = []
var input_manager: InputManager = null
var don_unlocked: bool = false

func register_fighter(fighter: Fighter) -> void:
	fighters.append(fighter)
	if input_manager:
		fighter.input_manager = input_manager

func setup_input_manager() -> void:
	input_manager = InputManager.new()
	add_child(input_manager)
	for fighter in fighters:
		fighter.input_manager = input_manager

func broadcast_round_reset() -> void:
	for fighter in fighters:
		fighter.reset_round_state()
	round_reset.emit()

func unlock_don() -> void:
	don_unlocked = true
```

Update `start_round()` to call `broadcast_round_reset()`.

- [ ] **Step 3: Commit**

```bash
git add scripts/core/game_manager.gd project.godot
git commit -m "feat: register GameManager as autoload, add round reset broadcast"
```

---

### Task 10: Delete Old Character Scripts

**Files:**
- Delete: `scripts/characters/glitterina.gd`
- Delete: `scripts/characters/lady_liberty.gd`
- Delete: `scripts/characters/miss_fire.gd`
- Delete: `scripts/characters/anita_win.gd`
- Delete: `scripts/characters/senator_stonewall.gd`
- Delete: `scripts/characters/mayor_mcbudget.gd`
- Delete: `scripts/characters/governor_gridlock.gd`
- Delete: `scripts/characters/rep_robocall.gd`

- [ ] **Step 1: Remove old character scripts**

```bash
cd /Users/mvacirca/dev/sashay-and-slay
rm scripts/characters/glitterina.gd
rm scripts/characters/lady_liberty.gd
rm scripts/characters/miss_fire.gd
rm scripts/characters/anita_win.gd
rm scripts/characters/senator_stonewall.gd
rm scripts/characters/mayor_mcbudget.gd
rm scripts/characters/governor_gridlock.gd
rm scripts/characters/rep_robocall.gd
```

- [ ] **Step 2: Commit**

```bash
git add -A scripts/characters/
git commit -m "chore: remove old character scripts, replaced by new roster"
```
