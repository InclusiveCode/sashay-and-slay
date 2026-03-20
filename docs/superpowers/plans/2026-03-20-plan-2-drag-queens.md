# Plan 2: Drag Queen Roster

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all 8 drag queen hero fighters with their unique specials, passives, and character-specific mechanics.

**Architecture:** Each queen extends the Fighter base class (updated in Plan 1). Override `use_special()`, `passive_proc()`, and `on_taunt_complete()` as needed. Character-specific resources use the secondary_resource system from Fighter.

**Tech Stack:** Godot 4.2, GDScript

**Spec:** `docs/superpowers/specs/2026-03-20-character-and-stage-redesign.md`
**Depends on:** Plan 1 (Core Engine Systems) must be complete.

---

### File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `scripts/characters/valencia_thunderclap.gd` | Counter/evasion fighter with vogue combo special |
| Create | `scripts/characters/mama_molotov.gd` | Rage tank with Riot Mode and burning brick |
| Create | `scripts/characters/anita_riot.gd` | Rushdown disruptor with input scrambling |
| Create | `scripts/characters/dixie_normous.gd` | Debuffer with stat-reducing reads |
| Create | `scripts/characters/siren_st_james.gd` | Precision fighter with super armor passive |
| Create | `scripts/characters/rex_hazard.gd` | Grappler with expanding grab range |
| Create | `scripts/characters/thornia_rose.gd` | Zone controller with growing thorns |
| Create | `scripts/characters/aurora_borealis.gd` | Ranged hybrid with spectral shield |
| Create | `scripts/core/thorn.gd` | Thornia's thorn object — grows over time, damages on contact |

---

### Task 1: Valencia Thunderclap

**Files:**
- Create: `scripts/characters/valencia_thunderclap.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Valencia Thunderclap — Ballroom Mother / Vogue Assassin
## Special: "10s Across the Board" — 5-hit timed vogue combo
## Passive: "The Floor is Yours" — 3 dodges triggers free counter

var _dodge_count: int = 0
var _in_special_combo: bool = false


func _ready() -> void:
	fighter_name = "Valencia Thunderclap"
	max_health = 95.0
	speed = 340.0
	jump_force = -520.0
	punch_damage = 6.0
	kick_damage = 8.0
	special_damage = 35.0
	special_name = "10s Across the Board"
	super._ready()


func get_catchphrase() -> String:
	return "You're giving me nothing to work with, and I'm still serving everything."


func passive_proc(_delta: float) -> void:
	# "The Floor is Yours" — tracked via on_dodge_successful()
	pass


func on_dodge_successful() -> void:
	_dodge_count += 1
	if _dodge_count >= 3:
		_dodge_count = 0
		# Free death drop counter-attack
		if opponent:
			opponent.take_damage(15.0, true)  # Unblockable
			passive_triggered.emit("The Floor is Yours")


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true
	_in_special_combo = true

	# 5-hit vogue combo — each hit is 7 dmg
	# In full implementation, each pose requires timed input
	# For now: sequential hits with brief pauses
	var total_damage = 0.0
	for i in range(5):
		# TODO: Add timed input check per pose
		# For now, all hits land
		var hit_damage = 7.0
		total_damage += hit_damage
		if opponent:
			opponent.take_damage(hit_damage, false)
			on_damage_dealt(hit_damage)
		await get_tree().create_timer(0.3).timeout

	# Bonus for perfect execution (all 5 hit)
	if total_damage >= 35.0 and opponent:
		opponent.take_damage(15.0, false)  # Bonus damage
		on_damage_dealt(15.0)

	_in_special_combo = false
	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_dodge_count = 0
	_in_special_combo = false
```

- [ ] **Step 2: Test in-engine**

Open the project in Godot, create a test scene with Valencia, verify:
- Stats load correctly
- Special move executes 5 hits
- Catchphrase returns correct string

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/valencia_thunderclap.gd
git commit -m "feat: add Valencia Thunderclap — vogue assassin with counter passive"
```

---

### Task 2: Mama Molotov

**Files:**
- Create: `scripts/characters/mama_molotov.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Mama Molotov — Stonewall Veteran / Rage Tank
## Special: "First Brick" — Unblockable burning projectile
## Passive: "We Were Always Here" — 20% reduced knockback
## Riot Mode: Below 30% HP — speed +30%, punch/kick +40%

var riot_mode: bool = false
const RIOT_HP_THRESHOLD: float = 0.3
const RIOT_SPEED_BONUS: float = 0.3
const RIOT_DAMAGE_BONUS: float = 0.4
const KNOCKBACK_REDUCTION: float = 0.8  # Takes 80% of normal knockback


func _ready() -> void:
	fighter_name = "Mama Molotov"
	max_health = 130.0
	speed = 260.0
	jump_force = -480.0
	punch_damage = 11.0
	kick_damage = 13.0
	special_damage = 30.0
	special_name = "First Brick"
	super._ready()


func get_catchphrase() -> String:
	return "I've been fighting fascists since before you were a fundraising email."


func passive_proc(_delta: float) -> void:
	var was_riot = riot_mode
	riot_mode = health <= max_health * RIOT_HP_THRESHOLD and health > 0
	if riot_mode and not was_riot:
		passive_triggered.emit("Riot Mode Activated")


func get_effective_speed() -> float:
	var base = super.get_effective_speed()
	if riot_mode:
		base *= (1.0 + RIOT_SPEED_BONUS)
	return base


func get_effective_punch() -> float:
	var base = super.get_effective_punch()
	if riot_mode:
		base *= (1.0 + RIOT_DAMAGE_BONUS)
	return base


func get_effective_kick() -> float:
	var base = super.get_effective_kick()
	if riot_mode:
		base *= (1.0 + RIOT_DAMAGE_BONUS)
	return base


func apply_knockback(direction: float, force: float) -> void:
	# "We Were Always Here" — 20% reduced knockback
	super.apply_knockback(direction, force * KNOCKBACK_REDUCTION)


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# Spawn unblockable burning projectile
	var proj = spawn_projectile(30.0, 400.0, true)

	# Spawn burning zone at projectile's expected impact area
	# Zone appears after brief delay (projectile travel time)
	await get_tree().create_timer(0.5).timeout
	var zone = spawn_burning_zone(3.0, 8.0, 120.0)
	zone.set_hurts_everyone(false)  # Only hurts opponent

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	riot_mode = false
```

- [ ] **Step 2: Test in-engine**

Verify Riot Mode activates below 30% HP and stat bonuses apply.

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/mama_molotov.gd
git commit -m "feat: add Mama Molotov — rage tank with Riot Mode and First Brick"
```

---

### Task 3: Anita Riot

**Files:**
- Create: `scripts/characters/anita_riot.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Anita Riot — Punk Protest Queen / Disruptor
## Special: "No Justice No Peace" — Shockwave + phantom protesters
## Passive: "Disruption" — Every 4th hit scrambles opponent input

const DISRUPTION_INTERVAL: int = 4
const SCRAMBLE_DURATION: float = 3.0

var _available_scrambles = [
	["left", "right"],
	["right", "left"],
	["punch", "kick"],
	["kick", "punch"],
]


func _ready() -> void:
	fighter_name = "Anita Riot"
	max_health = 90.0
	speed = 350.0
	jump_force = -520.0
	punch_damage = 8.0
	kick_damage = 9.0
	special_damage = 28.0
	special_name = "No Justice No Peace"
	super._ready()


func get_catchphrase() -> String:
	return "Your comfort was built on our silence. Sound check's over."


func on_hit_landed() -> void:
	super.on_hit_landed()
	# "Disruption" — every 4th hit scrambles an input
	if _hit_counter % DISRUPTION_INTERVAL == 0 and opponent and input_manager:
		var scramble = _available_scrambles[randi() % _available_scrambles.size()]
		var opp_prefix = "p2_" if is_player_one else "p1_"
		input_manager.scramble_input(opp_prefix, scramble[0], scramble[1], SCRAMBLE_DURATION)
		passive_triggered.emit("Disruption")


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# Megaphone shockwave — push opponent to wall (8 dmg)
	if opponent:
		opponent.take_damage(8.0, false)
		on_damage_dealt(8.0)
		var push_dir = 1.0 if opponent.global_position.x > global_position.x else -1.0
		opponent.apply_knockback(push_dir, 600.0)

	await get_tree().create_timer(0.4).timeout

	# Phantom protesters — 4 hits × 5 dmg
	for i in range(4):
		if opponent:
			opponent.take_damage(5.0, false)
			on_damage_dealt(5.0)
		await get_tree().create_timer(0.15).timeout

	is_attacking = false
```

- [ ] **Step 2: Test in-engine**

Verify input scramble triggers every 4th hit.

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/anita_riot.gd
git commit -m "feat: add Anita Riot — rushdown disruptor with input scrambling"
```

---

### Task 4: Dixie Normous

**Files:**
- Create: `scripts/characters/dixie_normous.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Dixie Normous — Southern Comedy Queen / Psychological Warfare
## Special: "The Library Is Open" — 5-hit combo that stacks stat reductions
## Passive: "Bless Your Heart" — Taunt after read heals 5 HP

var _last_read_landed: bool = false


func _ready() -> void:
	fighter_name = "Dixie Normous"
	max_health = 100.0
	speed = 290.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 8.0
	special_damage = 22.0
	special_name = "The Library Is Open"
	super._ready()


func get_catchphrase() -> String:
	return "Oh honey, I'm not being mean. The truth just hurts when it's this well-accessorized."


func attack(type: String, damage: float) -> void:
	await super.attack(type, damage)
	# Kicks are "reads" — apply stat reduction on hit
	if type == "kick" and opponent:
		opponent.apply_stat_reduction()
		_last_read_landed = true
		on_hit_landed()


func on_taunt_complete() -> void:
	# "Bless Your Heart" — heal 5 HP after successful read
	if _last_read_landed:
		health = min(health + 5.0, max_health)
		health_changed.emit(health)
		_last_read_landed = false
		passive_triggered.emit("Bless Your Heart")


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# "The Library Is Open" — 5-hit combo
	var hit_damages = [4.0, 4.0, 4.0, 4.0, 6.0]
	for i in range(5):
		if opponent:
			opponent.take_damage(hit_damages[i], false)
			opponent.apply_stat_reduction()  # Each hit reduces a stat
			on_damage_dealt(hit_damages[i])
		await get_tree().create_timer(0.25).timeout

	# Final hit drains opponent special meter
	if opponent:
		opponent.special_meter = 0.0
		opponent.special_meter_changed.emit(0.0)

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_last_read_landed = false
```

- [ ] **Step 2: Test in-engine**

Verify kick attacks reduce opponent stats, taunt after read heals.

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/dixie_normous.gd
git commit -m "feat: add Dixie Normous — debuffer with stat-reducing reads"
```

---

### Task 5: Siren St. James

**Files:**
- Create: `scripts/characters/siren_st_james.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Siren St. James — Pageant Assassin / Ice Queen
## Special: "Miss Congeniality" — Stun kiss + scepter combo
## Passive: "Poise Under Pressure" — Stand still 2s = super armor on next attack

var _still_timer: float = 0.0
var _has_super_armor: bool = false
var _super_armor_active: bool = false  # Currently absorbing a hit
const POISE_CHARGE_TIME: float = 2.0


func _ready() -> void:
	fighter_name = "Siren St. James"
	max_health = 105.0
	speed = 240.0
	jump_force = -480.0
	punch_damage = 12.0
	kick_damage = 14.0
	special_damage = 32.0
	special_name = "Miss Congeniality"
	super._ready()


func get_catchphrase() -> String:
	return "I'd wish you luck, but it won't help."


func passive_proc(delta: float) -> void:
	# "Poise Under Pressure" — standing still charges super armor
	if velocity.length() < 1.0 and is_on_floor() and not is_attacking and not is_taunting:
		_still_timer += delta
		if _still_timer >= POISE_CHARGE_TIME and not _has_super_armor:
			_has_super_armor = true
			passive_triggered.emit("Poise Under Pressure")
	else:
		_still_timer = 0.0


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _has_super_armor and is_attacking:
		# Absorb the hit without flinching
		_has_super_armor = false
		# Still take the damage but don't interrupt attack
		health -= amount * (0.2 if is_blocking and not unblockable else 1.0)
		health = max(health, 0.0)
		health_changed.emit(health)
		if health <= 0:
			defeated.emit()
		return
	super.take_damage(amount, unblockable)


func attack(type: String, damage: float) -> void:
	# Consume super armor on attack start
	if _has_super_armor:
		_super_armor_active = true
	await super.attack(type, damage)
	_super_armor_active = false


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# Kiss projectile that stuns
	var kiss = spawn_projectile(0.0, 400.0, false)
	# TODO: On hit, stun opponent for 1.5 seconds

	await get_tree().create_timer(0.8).timeout

	# Scepter combo — 3 hits
	var hit_damages = [8.0, 10.0, 14.0]
	for i in range(3):
		if opponent:
			opponent.take_damage(hit_damages[i], false)
			on_damage_dealt(hit_damages[i])
		await get_tree().create_timer(0.2).timeout

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_still_timer = 0.0
	_has_super_armor = false
	_super_armor_active = false
```

- [ ] **Step 2: Test in-engine**

Verify super armor charges after standing still 2 seconds.

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/siren_st_james.gd
git commit -m "feat: add Siren St. James — precision fighter with super armor passive"
```

---

### Task 6: Rex Hazard

**Files:**
- Create: `scripts/characters/rex_hazard.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Rex Hazard — Drag King / Leather Daddy Grappler
## Special: "Daddy Issues" — Unblockable grab with pile-driver
## Passive: "Masc 4 Massacre" — Grabs increase grab range for round

var grab_range: float = 60.0
const BASE_GRAB_RANGE: float = 60.0
const GRAB_RANGE_INCREMENT: float = 10.0
const MAX_GRAB_RANGE: float = 120.0


func _ready() -> void:
	fighter_name = "Rex Hazard"
	max_health = 115.0
	speed = 270.0
	jump_force = -490.0
	punch_damage = 10.0
	kick_damage = 11.0
	special_damage = 30.0
	special_name = "Daddy Issues"
	super._ready()


func get_catchphrase() -> String:
	return "I'm not your daddy. But I am your problem."


func _is_in_grab_range() -> bool:
	if not opponent:
		return false
	return abs(global_position.x - opponent.global_position.x) <= grab_range


func attack(type: String, damage: float) -> void:
	if type == "kick" and _is_in_grab_range() and opponent:
		# Kick becomes a grab when in range
		await _perform_grab()
		return
	await super.attack(type, damage)


func _perform_grab() -> void:
	is_attacking = true
	if opponent:
		# Position-dependent slam
		var near_wall = abs(opponent.global_position.x) > 500  # Near stage edge
		var in_air = not opponent.is_on_floor()

		var grab_damage = kick_damage * 1.5
		opponent.take_damage(grab_damage, true)  # Grabs are unblockable
		on_damage_dealt(grab_damage)
		on_hit_landed()

		# "Masc 4 Massacre" — increase grab range
		grab_range = min(grab_range + GRAB_RANGE_INCREMENT, MAX_GRAB_RANGE)
		passive_triggered.emit("Masc 4 Massacre")

	await get_tree().create_timer(0.4).timeout
	is_attacking = false


func use_special() -> void:
	if special_meter < 100.0:
		return
	if not _is_in_grab_range():
		return  # Must be in grab range
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	if opponent:
		# Headbutt (10 dmg)
		opponent.take_damage(10.0, true)
		on_damage_dealt(10.0)
		await get_tree().create_timer(0.3).timeout

		# Pile-drive (20 dmg)
		opponent.take_damage(20.0, true)
		on_damage_dealt(20.0)
		# TODO: Camera shake effect

	await get_tree().create_timer(0.5).timeout
	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	grab_range = BASE_GRAB_RANGE
```

- [ ] **Step 2: Test in-engine**

Verify grab range increases with each successful grab.

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/rex_hazard.gd
git commit -m "feat: add Rex Hazard — grappler with expanding grab range"
```

---

### Task 7: Thornia Rose + Thorn Object

**Files:**
- Create: `scripts/core/thorn.gd`
- Create: `scripts/characters/thornia_rose.gd`

- [ ] **Step 1: Create Thorn object**

Create `scripts/core/thorn.gd`:

```gdscript
class_name Thorn
extends Area2D

## A planted thorn that grows over time and damages on contact.

var age: float = 0.0
var owner_fighter: Fighter = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Set up collision shape
	var shape = CircleShape2D.new()
	shape.radius = 15.0
	var collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


func _physics_process(delta: float) -> void:
	age += delta


func get_damage() -> float:
	# Overgrowth: 2 dmg at 0-3s, 4 dmg at 3-6s, 6 dmg at 6s+
	if age < 3.0:
		return 2.0
	elif age < 6.0:
		return 4.0
	else:
		return 6.0


func _on_body_entered(body: Node2D) -> void:
	if body is Fighter and body != owner_fighter:
		body.take_damage(get_damage(), false)
```

- [ ] **Step 2: Create Thornia Rose character**

Create `scripts/characters/thornia_rose.gd`:

```gdscript
extends Fighter

## Thornia Rose — Bearded Queen / Eco-Witch / Zone Controller
## Special: "Reclaiming My Thyme" — Full-stage vine attack with DOT
## Passive: "Overgrowth" — Planted thorns grow stronger over time

var thorns: Array[Thorn] = []
const MAX_THORNS: int = 5


func _ready() -> void:
	fighter_name = "Thornia Rose"
	max_health = 100.0
	speed = 280.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 9.0
	special_damage = 25.0
	special_name = "Reclaiming My Thyme"
	super._ready()


func get_catchphrase() -> String:
	return "Nature doesn't negotiate. Neither do I."


func attack(type: String, damage: float) -> void:
	if type == "kick":
		# Kick plants a thorn at current position
		_plant_thorn()
		# Still do the kick attack
	await super.attack(type, damage)


func _plant_thorn() -> void:
	# Remove oldest if at max
	if thorns.size() >= MAX_THORNS:
		var oldest = thorns.pop_front()
		oldest.queue_free()

	var thorn = Thorn.new()
	thorn.owner_fighter = self
	thorn.position = global_position + Vector2(0, 10)
	get_parent().add_child(thorn)
	thorns.append(thorn)


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# "Reclaiming My Thyme" — root opponent + DOT
	if opponent:
		# Root opponent for 3 seconds
		var original_speed = opponent.speed
		opponent.speed = 0.0

		# DOT: 5 dmg/second for 5 seconds
		for i in range(5):
			if opponent:
				opponent.take_damage(5.0, false)
				on_damage_dealt(5.0)
			await get_tree().create_timer(1.0).timeout

		# Restore speed
		if opponent:
			opponent.speed = original_speed

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	for thorn in thorns:
		if is_instance_valid(thorn):
			thorn.queue_free()
	thorns.clear()
```

- [ ] **Step 3: Test in-engine**

Verify thorns plant on kick, max 5, and damage increases with age.

- [ ] **Step 4: Commit**

```bash
git add scripts/core/thorn.gd scripts/characters/thornia_rose.gd
git commit -m "feat: add Thornia Rose — zone controller with growing thorns"
```

---

### Task 8: Aurora Borealis

**Files:**
- Create: `scripts/characters/aurora_borealis.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Aurora Borealis — Cosmic Nonbinary Queen / Light Wielder
## Special: "Prismatic Judgment" — Rainbow beam convergence + self heal
## Passive: "Spectral Shield" — After taking 30 dmg, absorb + reflect next hit

var _damage_absorbed: float = 0.0
var _shield_charged: bool = false
const SHIELD_CHARGE_THRESHOLD: float = 30.0
const SHIELD_REFLECT_DAMAGE: float = 8.0
var _has_double_jump: bool = true


func _ready() -> void:
	fighter_name = "Aurora Borealis"
	max_health = 95.0
	speed = 300.0
	jump_force = -480.0
	punch_damage = 6.0
	kick_damage = 7.0
	special_damage = 28.0
	special_name = "Prismatic Judgment"
	super._ready()


func get_catchphrase() -> String:
	return "You tried to erase us from the sky. Look up."


func handle_input(prefix: String) -> void:
	super.handle_input(prefix)
	# Double jump
	if Input.is_action_just_pressed(prefix + "up") and not is_on_floor() and _has_double_jump:
		velocity.y = jump_force * 0.8
		_has_double_jump = false

	if is_on_floor():
		_has_double_jump = true


func attack(type: String, damage: float) -> void:
	if type == "punch":
		# Punch fires a beam projectile instead of melee
		spawn_projectile(punch_damage, 500.0, false)
		on_hit_landed()
		return
	await super.attack(type, damage)


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _shield_charged:
		# Absorb hit completely and reflect
		_shield_charged = false
		if opponent:
			var reflect = spawn_projectile(SHIELD_REFLECT_DAMAGE, 400.0, false)
		passive_triggered.emit("Spectral Shield — Reflected!")
		return

	super.take_damage(amount, unblockable)

	# Track damage for shield charging
	_damage_absorbed += amount
	if _damage_absorbed >= SHIELD_CHARGE_THRESHOLD:
		_shield_charged = true
		_damage_absorbed = 0.0
		passive_triggered.emit("Spectral Shield Charged")


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# "Prismatic Judgment" — ascend, beams converge, explode
	# TODO: Visual — ascend above stage
	velocity.y = jump_force * 1.5

	await get_tree().create_timer(0.8).timeout

	if opponent:
		opponent.take_damage(28.0, false)
		on_damage_dealt(28.0)
		# Heal 20% of damage dealt
		var heal = 28.0 * 0.2
		health = min(health + heal, max_health)
		health_changed.emit(health)

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_damage_absorbed = 0.0
	_shield_charged = false
	_has_double_jump = true
```

- [ ] **Step 2: Test in-engine**

Verify shield charges after 30 damage taken, absorbs and reflects next hit.

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/aurora_borealis.gd
git commit -m "feat: add Aurora Borealis — ranged hybrid with spectral shield"
```
