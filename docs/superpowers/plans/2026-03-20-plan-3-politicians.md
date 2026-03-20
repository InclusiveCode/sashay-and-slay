# Plan 3: Politician Roster + Final Boss

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all 7 politician villain fighters + Don the Con final boss with ego meter, phase transitions, and unique mechanics (Capital resource, Mother NPC, barriers, move banning).

**Architecture:** Each politician extends Fighter. Complex fighters (Elmo Musk, Mike Dense, Greg Ablot) spawn companion objects. Don the Con has a boss state machine for phase transitions.

**Tech Stack:** Godot 4.2, GDScript

**Spec:** `docs/superpowers/specs/2026-03-20-character-and-stage-redesign.md`
**Depends on:** Plan 1 (Core Engine), Plan 2 (Drag Queens — for testing matchups)

---

### File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `scripts/characters/ron_desanctimonious.gd` | Move-banning culture warrior |
| Create | `scripts/characters/marjorie_trailer_queen.gd` | Chaotic rushdown with self-damage |
| Create | `scripts/characters/cancun_cruz.gd` | Coward zoner with flee dash |
| Create | `scripts/characters/moscow_mitch.gd` | Stall tank with obstruction meter |
| Create | `scripts/characters/elmo_musk.gd` | Gadget fighter with Capital resource |
| Create | `scripts/characters/mike_dense.gd` | Holy warrior with Mother NPC |
| Create | `scripts/characters/greg_ablot.gd` | Trap specialist with barriers |
| Create | `scripts/characters/don_the_con.gd` | Final boss with Ego Meter + Phase 2 |
| Create | `scripts/characters/companions/mother_npc.gd` | Mike Dense's auto-blocking companion |
| Create | `scripts/characters/companions/attack_drone.gd` | Elmo Musk's attack drone |
| Create | `scripts/characters/companions/shield_drone.gd` | Elmo Musk's shield drone |
| Create | `scripts/core/barrier.gd` | Greg Ablot's destructible barrier |

---

### Task 1: Ron DeSanctimonious

**Files:**
- Create: `scripts/characters/ron_desanctimonious.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Ron DeSanctimonious — Culture Warrior / Move Denial
## Special: "Don't Say Slay" — 4-second total silence
## Passive: "Parental Advisory" — 15% DR when opponent uses special

var _ban_timer: float = 0.0
const BAN_INTERVAL: float = 15.0
var _parental_advisory_timer: float = 0.0
var _parental_advisory_active: bool = false
const PA_DURATION: float = 5.0
const PA_REDUCTION: float = 0.85


func _ready() -> void:
	fighter_name = "Ron DeSanctimonious"
	max_health = 110.0
	speed = 280.0
	jump_force = -490.0
	punch_damage = 9.0
	kick_damage = 10.0
	special_damage = 0.0
	special_name = "Don't Say Slay"
	super._ready()


func get_catchphrase() -> String:
	return "This fight has been deemed inappropriate for all audiences."


func passive_proc(delta: float) -> void:
	# Auto-ban a move every 15 seconds
	_ban_timer += delta
	if _ban_timer >= BAN_INTERVAL and input_manager and opponent:
		_ban_timer = 0.0
		var opp_prefix = "p2_" if is_player_one else "p1_"
		# Ban punch or kick (not block)
		var bannable = ["punch", "kick"]
		var action = bannable[randi() % bannable.size()]

		# Max 2 bans — evict oldest if at cap
		if input_manager.get_active_ban_count(opp_prefix) >= 2:
			input_manager.evict_oldest_ban(opp_prefix)
		input_manager.ban_input(opp_prefix, action, BAN_INTERVAL)

	# "Parental Advisory" timer
	if _parental_advisory_active:
		_parental_advisory_timer -= delta
		if _parental_advisory_timer <= 0:
			_parental_advisory_active = false


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _parental_advisory_active:
		amount *= PA_REDUCTION
	super.take_damage(amount, unblockable)


func _enter_tree() -> void:
	# Connect to opponent's special_used signal when available
	if opponent:
		opponent.special_used.connect(_on_opponent_used_special)

func _on_opponent_used_special() -> void:
	# Called when opponent uses their special — triggers Parental Advisory
	_parental_advisory_active = true
	_parental_advisory_timer = PA_DURATION
	passive_triggered.emit("Parental Advisory")


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)

	# "Don't Say Slay" — 4 seconds of total silence
	if input_manager:
		var opp_prefix = "p2_" if is_player_one else "p1_"
		input_manager.silence_player(opp_prefix, 4.0)


func reset_round_state() -> void:
	super.reset_round_state()
	_ban_timer = 0.0
	_parental_advisory_timer = 0.0
	_parental_advisory_active = false
```

- [ ] **Step 2: Commit**

```bash
git add scripts/characters/ron_desanctimonious.gd
git commit -m "feat: add Ron DeSanctimonious — move-banning culture warrior"
```

---

### Task 2: Marjorie Trailer Queen

**Files:**
- Create: `scripts/characters/marjorie_trailer_queen.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Marjorie Trailer Queen — Chaotic Rushdown
## Special: "Jewish Space Laser" — Tracking laser + ground fire
## Passive: "Do Your Own Research" — Faster recovery, next hit 1.5x after knockdown

var _next_hit_boosted: bool = false
const SELF_HIT_CHANCE: float = 0.10
const CRIT_CHANCE: float = 0.20
const CRIT_MULTIPLIER: float = 1.5


func _ready() -> void:
	fighter_name = "Marjorie Trailer Queen"
	max_health = 95.0
	speed = 330.0
	jump_force = -520.0
	punch_damage = 9.0
	kick_damage = 11.0
	special_damage = 30.0
	special_name = "Jewish Space Laser"
	super._ready()


func get_catchphrase() -> String:
	return "I did my own research! On Facebook!"


func attack(type: String, damage: float) -> void:
	if type != "special":
		# Self-damage check
		if randf() < SELF_HIT_CHANCE:
			take_damage(damage * 0.5, true)
			return  # Attack whiffs — hit self instead

		# Crit check or boosted next hit
		if _next_hit_boosted or randf() < CRIT_CHANCE:
			damage *= CRIT_MULTIPLIER
			_next_hit_boosted = false

	await super.attack(type, damage)


func take_damage(amount: float, unblockable: bool = false) -> void:
	super.take_damage(amount, unblockable)
	# "Do Your Own Research" — after being knocked down, next hit is boosted
	# Simplified: any significant hit triggers recovery boost
	if amount >= 10.0:
		_next_hit_boosted = true
		passive_triggered.emit("Do Your Own Research")


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# Tracking laser — 30 dmg to opponent
	if opponent:
		opponent.take_damage(30.0, false)
		on_damage_dealt(30.0)

	# Ground fire — hurts both fighters
	var zone = spawn_burning_zone(4.0, 4.0, 200.0)
	zone.set_hurts_everyone(true)  # Damages Marjorie too

	await get_tree().create_timer(0.5).timeout
	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_next_hit_boosted = false
```

- [ ] **Step 2: Commit**

```bash
git add scripts/characters/marjorie_trailer_queen.gd
git commit -m "feat: add Marjorie Trailer Queen — chaotic rushdown with self-damage"
```

---

### Task 3: Cancun Cruz

**Files:**
- Create: `scripts/characters/cancun_cruz.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Cancun Cruz — Coward Zoner
## Special: "Zodiac Filibuster" — Sleep zone + suitcase slam
## Passive: "Fled the State" — Below 30% HP, faster flee and speed boost

var _flee_cooldown: float = 0.0
var _is_fleeing: bool = false
const FLEE_COOLDOWN_BASE: float = 3.0
const FLEE_DURATION: float = 0.5
const FLEE_DISTANCE: float = 300.0
const LOW_HP_THRESHOLD: float = 0.3
const LOW_HP_SPEED_BONUS: float = 0.2
const EXECUTE_THRESHOLD: float = 0.4
const EXECUTE_BONUS: float = 0.25


func _ready() -> void:
	fighter_name = "Cancun Cruz"
	max_health = 100.0
	speed = 310.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 8.0
	special_damage = 26.0
	special_name = "Zodiac Filibuster"
	super._ready()


func get_catchphrase() -> String:
	return "I'd love to fight, but I have a flight to catch."


func passive_proc(delta: float) -> void:
	if _flee_cooldown > 0:
		_flee_cooldown -= delta


func get_effective_speed() -> float:
	var base = super.get_effective_speed()
	if health <= max_health * LOW_HP_THRESHOLD:
		base *= (1.0 + LOW_HP_SPEED_BONUS)
	return base


func handle_input(prefix: String) -> void:
	super.handle_input(prefix)
	# Double-tap back to flee
	# Simplified: taunt button triggers flee dash
	if Input.is_action_just_pressed(prefix + "taunt") and _flee_cooldown <= 0:
		_perform_flee()


func _perform_flee() -> void:
	_is_fleeing = true
	var flee_dir = -1.0 if facing_right else 1.0  # Flee away from opponent
	velocity.x = flee_dir * FLEE_DISTANCE / FLEE_DURATION

	var cooldown = FLEE_COOLDOWN_BASE
	if health <= max_health * LOW_HP_THRESHOLD:
		cooldown *= 0.5  # "Fled the State" — halved cooldown
		passive_triggered.emit("Fled the State")
	_flee_cooldown = cooldown

	await get_tree().create_timer(FLEE_DURATION).timeout
	_is_fleeing = false


func attack(type: String, damage: float) -> void:
	var final_damage = damage
	# 25% bonus damage to opponents below 40% HP
	if opponent and opponent.health <= opponent.max_health * EXECUTE_THRESHOLD:
		final_damage *= (1.0 + EXECUTE_BONUS)
	await super.attack(type, final_damage)


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# Sleep zone — 120px radius growing to 200px over 2 seconds
	# If opponent is in range, they fall asleep then get hit
	if opponent:
		var dist = abs(global_position.x - opponent.global_position.x)
		# Wait for zone to grow
		await get_tree().create_timer(1.0).timeout
		if dist <= 200.0:
			# Opponent falls asleep (rooted 2 seconds via temp speed)
			opponent.apply_temp_speed(0.0, 2.0)
			await get_tree().create_timer(2.0).timeout
			# Suitcase slam
			opponent.take_damage(26.0, false)
			on_damage_dealt(26.0)

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_flee_cooldown = 0.0
	_is_fleeing = false
```

- [ ] **Step 2: Commit**

```bash
git add scripts/characters/cancun_cruz.gd
git commit -m "feat: add Cancun Cruz — coward zoner with flee dash"
```

---

### Task 4: Moscow Mitch

**Files:**
- Create: `scripts/characters/moscow_mitch.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Moscow Mitch — Stall Tank
## Special: "Obstruct & Destroy" — 4s immunity, stored damage shockwave
## Passive: "Table the Motion" — Blocking builds obstruction meter for 2x hit

var obstruction_meter: float = 0.0
const OBSTRUCTION_MAX: float = 40.0
var _obstruction_charged: bool = false
var _immunity_active: bool = false
var _stored_damage: float = 0.0


func _ready() -> void:
	fighter_name = "Moscow Mitch"
	max_health = 140.0
	speed = 200.0
	jump_force = -450.0
	punch_damage = 8.0
	kick_damage = 9.0
	special_damage = 20.0
	special_name = "Obstruct & Destroy"
	super._ready()


func get_catchphrase() -> String:
	return "The motion to defeat me... is tabled."


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _immunity_active:
		_stored_damage += amount
		return

	var was_blocking = is_blocking
	super.take_damage(amount, unblockable)

	# "Table the Motion" — blocking builds obstruction meter
	if was_blocking and not unblockable:
		obstruction_meter += amount  # Track raw damage blocked
		set_secondary_resource(obstruction_meter)
		if obstruction_meter >= OBSTRUCTION_MAX and not _obstruction_charged:
			_obstruction_charged = true
			passive_triggered.emit("Table the Motion — CHARGED")


func attack(type: String, damage: float) -> void:
	if _obstruction_charged:
		# Next attack is 2x and unblockable
		damage *= 2.0
		_obstruction_charged = false
		obstruction_meter = 0.0
		set_secondary_resource(0.0)
		# TODO: Make this hit unblockable
	await super.attack(type, damage)


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# 4 seconds of total damage immunity
	_immunity_active = true
	_stored_damage = 0.0

	await get_tree().create_timer(4.0).timeout

	_immunity_active = false

	# Release stored damage + 20 base as shockwave
	var release_damage = _stored_damage + 20.0
	if opponent:
		opponent.take_damage(release_damage, true)  # Unblockable shockwave
		on_damage_dealt(release_damage)

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	obstruction_meter = 0.0
	_obstruction_charged = false
	_immunity_active = false
	_stored_damage = 0.0
```

- [ ] **Step 2: Commit**

```bash
git add scripts/characters/moscow_mitch.gd
git commit -m "feat: add Moscow Mitch — stall tank with obstruction meter"
```

---

### Task 5: Elmo Musk + Drones

**Files:**
- Create: `scripts/characters/companions/attack_drone.gd`
- Create: `scripts/characters/companions/shield_drone.gd`
- Create: `scripts/characters/elmo_musk.gd`

- [ ] **Step 1: Create AttackDrone**

```bash
mkdir -p /Users/mvacirca/dev/sashay-and-slay/scripts/characters/companions
```

Create `scripts/characters/companions/attack_drone.gd`:

```gdscript
class_name AttackDrone
extends Area2D

## Attack drone — fires 3 shots of 4 dmg each, then expires.

var owner_fighter: Fighter = null
var target: Fighter = null
var hp: float = 10.0
var capital_cost: int = 15
var _lifetime: float = 0.0
var _shots_fired: int = 0
var _shot_timer: float = 0.0
const MAX_SHOTS: int = 3
const SHOT_INTERVAL: float = 2.0
const MAX_LIFETIME: float = 8.0
const SHOT_DAMAGE: float = 4.0


func _physics_process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= MAX_LIFETIME or _shots_fired >= MAX_SHOTS:
		queue_free()
		return

	# Follow owner at offset
	if owner_fighter:
		var target_pos = owner_fighter.global_position + Vector2(0, -60)
		global_position = global_position.lerp(target_pos, delta * 3.0)

	# Fire at target
	_shot_timer += delta
	if _shot_timer >= SHOT_INTERVAL and target and _shots_fired < MAX_SHOTS:
		_shot_timer = 0.0
		_shots_fired += 1
		if owner_fighter:
			var proj = owner_fighter.spawn_projectile(SHOT_DAMAGE, 500.0, false)
			proj.position = global_position


func take_hit(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		# "Move Fast Break Things" — refund to owner
		if owner_fighter and owner_fighter.has_method("on_drone_destroyed"):
			owner_fighter.on_drone_destroyed(capital_cost)
		queue_free()
```

- [ ] **Step 2: Create ShieldDrone**

Create `scripts/characters/companions/shield_drone.gd`:

```gdscript
class_name ShieldDrone
extends Area2D

## Shield drone — blocks one hit for owner, then expires.

var owner_fighter: Fighter = null
var hp: float = 1.0
var capital_cost: int = 25
var _lifetime: float = 0.0
const MAX_LIFETIME: float = 10.0
var _has_blocked: bool = false


func _physics_process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= MAX_LIFETIME or _has_blocked:
		queue_free()
		return

	# Stay in front of owner
	if owner_fighter:
		var offset = 40.0 if owner_fighter.facing_right else -40.0
		var target_pos = owner_fighter.global_position + Vector2(offset, -20)
		global_position = global_position.lerp(target_pos, delta * 5.0)


func block_hit() -> bool:
	if not _has_blocked:
		_has_blocked = true
		# Refund on destruction
		if owner_fighter and owner_fighter.has_method("on_drone_destroyed"):
			owner_fighter.on_drone_destroyed(capital_cost)
		queue_free()
		return true
	return false
```

- [ ] **Step 3: Create Elmo Musk**

Create `scripts/characters/elmo_musk.gd`:

```gdscript
extends Fighter

## Elmo Musk — Tech Bro with Capital Resource
## Special: "Hostile Takeover" — Electric floor + platform removal
## Passive: "Move Fast Break Things" — Drone destruction refunds 150% Capital

var capital: int = 50
const CAPITAL_MAX: int = 100
const CAPITAL_PER_SECOND: float = 1.0
var _capital_timer: float = 0.0
var active_drones: Array = []
const MAX_DRONES: int = 2

const COST_ATTACK_DRONE: int = 15
const COST_SHIELD_DRONE: int = 25
const COST_SATELLITE: int = 40


func _ready() -> void:
	fighter_name = "Elmo Musk"
	max_health = 100.0
	speed = 290.0
	jump_force = -500.0
	punch_damage = 7.0
	kick_damage = 8.0
	special_damage = 28.0
	special_name = "Hostile Takeover"
	secondary_resource = 50.0
	secondary_resource_max = 100.0
	super._ready()


func get_catchphrase() -> String:
	return "I'm not a villain. I'm a disruptor. Same thing."


func passive_proc(delta: float) -> void:
	# Gain 1 Capital per second
	_capital_timer += delta
	if _capital_timer >= 1.0:
		_capital_timer -= 1.0
		capital = min(capital + 1, CAPITAL_MAX)
		set_secondary_resource(float(capital))

	# Clean up dead drones
	active_drones = active_drones.filter(func(d): return is_instance_valid(d))


func on_taunt_complete() -> void:
	# Taunt opens spend menu — direction determines purchase
	# Simplified: taunt deploys attack drone (cheapest)
	# TODO: Taunt + direction for different purchases
	_deploy_attack_drone()


func _deploy_attack_drone() -> void:
	if capital < COST_ATTACK_DRONE or active_drones.size() >= MAX_DRONES:
		return
	capital -= COST_ATTACK_DRONE
	set_secondary_resource(float(capital))
	var drone = AttackDrone.new()
	drone.owner_fighter = self
	drone.target = opponent
	drone.capital_cost = COST_ATTACK_DRONE
	drone.position = global_position + Vector2(0, -60)
	get_parent().add_child(drone)
	active_drones.append(drone)


func deploy_shield_drone() -> void:
	if capital < COST_SHIELD_DRONE or active_drones.size() >= MAX_DRONES:
		return
	capital -= COST_SHIELD_DRONE
	set_secondary_resource(float(capital))
	var drone = ShieldDrone.new()
	drone.owner_fighter = self
	drone.capital_cost = COST_SHIELD_DRONE
	drone.position = global_position + Vector2(30, -20)
	get_parent().add_child(drone)
	active_drones.append(drone)


func satellite_strike() -> void:
	if capital < COST_SATELLITE:
		return
	capital -= COST_SATELLITE
	set_secondary_resource(float(capital))
	if opponent:
		opponent.take_damage(15.0, false)
		on_damage_dealt(15.0)


func on_drone_destroyed(drone_capital_cost: int) -> void:
	# "Move Fast Break Things" — 150% refund
	var refund = int(drone_capital_cost * 1.5)
	capital = min(capital + refund, CAPITAL_MAX)
	set_secondary_resource(float(capital))
	passive_triggered.emit("Move Fast Break Things")


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# "Hostile Takeover" — stun + electric floor
	if opponent:
		# 1 second stun via temp speed
		opponent.apply_temp_speed(0.0, 1.0)
		await get_tree().create_timer(1.0).timeout

	# Electric floor — 2 dmg/sec for 6 seconds
	var zone = spawn_burning_zone(2.0, 6.0, 800.0)  # Wide zone
	zone.set_hurts_everyone(false)

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	capital = 50
	_capital_timer = 0.0
	set_secondary_resource(50.0)
	for drone in active_drones:
		if is_instance_valid(drone):
			drone.queue_free()
	active_drones.clear()
```

- [ ] **Step 4: Commit**

```bash
git add scripts/characters/companions/ scripts/characters/elmo_musk.gd
git commit -m "feat: add Elmo Musk — tech bro with Capital resource and drones"
```

---

### Task 6: Mike Dense + Mother NPC

**Files:**
- Create: `scripts/characters/companions/mother_npc.gd`
- Create: `scripts/characters/mike_dense.gd`

- [ ] **Step 1: Create Mother NPC**

Create `scripts/characters/companions/mother_npc.gd`:

```gdscript
class_name MotherNPC
extends Node2D

## "Mother" — follows Mike Dense, auto-blocks one attack every 10 seconds.

var owner_fighter: Fighter = null
var _cooldown: float = 0.0
var _active: bool = true
const BLOCK_COOLDOWN: float = 10.0


func _physics_process(delta: float) -> void:
	if not owner_fighter:
		return

	# Follow Mike
	var offset = -40.0 if owner_fighter.facing_right else 40.0
	var target_pos = owner_fighter.global_position + Vector2(offset, 0)
	global_position = global_position.lerp(target_pos, delta * 3.0)

	# Cooldown
	if not _active:
		_cooldown -= delta
		if _cooldown <= 0:
			_active = true
			visible = true


func can_block() -> bool:
	return _active


func block_attack() -> void:
	if not _active:
		return
	_active = false
	_cooldown = BLOCK_COOLDOWN
	visible = false  # Disappears after blocking


func reset() -> void:
	_active = true
	_cooldown = 0.0
	visible = true
```

- [ ] **Step 2: Create Mike Dense**

Create `scripts/characters/mike_dense.gd`:

```gdscript
extends Fighter

## Mike Dense — Holy Warrior
## Special: "Conversion Therapy" — Grab + control reversal + meter drain
## Passive: "Mother Knows Best" — Mother NPC auto-blocks one hit/10s

var mother: MotherNPC = null
var _pray_timer: float = 0.0
var _pray_charged: bool = false
var _is_praying: bool = false
const PRAY_CHARGE_TIME: float = 3.0
const PRAY_DAMAGE_MULT: float = 2.0


func _ready() -> void:
	fighter_name = "Mike Dense"
	max_health = 105.0
	speed = 270.0
	jump_force = -490.0
	punch_damage = 9.0
	kick_damage = 10.0
	special_damage = 24.0
	special_name = "Conversion Therapy"
	super._ready()

	# Spawn Mother
	mother = MotherNPC.new()
	mother.owner_fighter = self


func _enter_tree() -> void:
	# Add Mother to the scene when Mike enters
	if mother and not mother.is_inside_tree():
		get_parent().call_deferred("add_child", mother)


func get_catchphrase() -> String:
	return "Mother wouldn't approve of this."


func passive_proc(delta: float) -> void:
	# Pray stance: hold block + up
	var prefix = "p1_" if is_player_one else "p2_"
	_is_praying = is_blocking and Input.is_action_pressed(prefix + "up")

	if _is_praying:
		_pray_timer += delta
		if _pray_timer >= PRAY_CHARGE_TIME and not _pray_charged:
			_pray_charged = true
			passive_triggered.emit("Prayer Charged")
	else:
		_pray_timer = 0.0


func take_damage(amount: float, unblockable: bool = false) -> void:
	# "Mother Knows Best" — Mother blocks one hit
	if mother and mother.can_block() and not unblockable:
		mother.block_attack()
		passive_triggered.emit("Mother Knows Best")
		return  # Completely absorbed
	super.take_damage(amount, unblockable)


func attack(type: String, damage: float) -> void:
	if _pray_charged:
		damage *= PRAY_DAMAGE_MULT
		_pray_charged = false
	await super.attack(type, damage)


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	if opponent:
		# Grab — 24 dmg
		opponent.take_damage(24.0, true)
		on_damage_dealt(24.0)

		# Reverse controls for 4 seconds
		if input_manager:
			var opp_prefix = "p2_" if is_player_one else "p1_"
			input_manager.scramble_input(opp_prefix, "left", "right", 4.0)
			input_manager.scramble_input(opp_prefix, "right", "left", 4.0)

		# Drain 30 special meter
		opponent.special_meter = max(opponent.special_meter - 30.0, 0.0)
		opponent.special_meter_changed.emit(opponent.special_meter)

	await get_tree().create_timer(0.5).timeout
	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_pray_timer = 0.0
	_pray_charged = false
	_is_praying = false
	if mother:
		mother.reset()
```

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/companions/mother_npc.gd scripts/characters/mike_dense.gd
git commit -m "feat: add Mike Dense — holy warrior with Mother NPC companion"
```

---

### Task 7: Greg Ablot + Barriers

**Files:**
- Create: `scripts/core/barrier.gd`
- Create: `scripts/characters/greg_ablot.gd`

- [ ] **Step 1: Create Barrier**

Create `scripts/core/barrier.gd`:

```gdscript
class_name Barrier
extends StaticBody2D

## Destructible barrier placed by Greg Ablot.

var hp: float = 15.0
var owner_fighter: Fighter = null
const CONTACT_DAMAGE: float = 5.0

@onready var collision = CollisionShape2D.new()
@onready var hitbox = Area2D.new()


func _ready() -> void:
	# Physical collision (blocks movement)
	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 80)
	collision.shape = shape
	add_child(collision)

	# Hitbox for contact damage
	var hitbox_shape = RectangleShape2D.new()
	hitbox_shape.size = Vector2(30, 80)
	var hitbox_collision = CollisionShape2D.new()
	hitbox_collision.shape = hitbox_shape
	hitbox.add_child(hitbox_collision)
	add_child(hitbox)
	hitbox.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Fighter and body != owner_fighter:
		body.take_damage(CONTACT_DAMAGE, false)


func take_hit(damage: float) -> void:
	hp -= damage
	if hp <= 0:
		queue_free()
```

- [ ] **Step 2: Create Greg Ablot**

Create `scripts/characters/greg_ablot.gd`:

```gdscript
extends Fighter

## Greg Ablot — Trap Specialist
## Special: "Operation Lone Star" — National Guard rush
## Passive: "Pulled Up the Ladder" — 30% DR behind own barriers

var barriers: Array[Barrier] = []
const MAX_BARRIERS: int = 3
const BEHIND_BARRIER_DR: float = 0.7


func _ready() -> void:
	fighter_name = "Greg Ablot"
	max_health = 110.0
	speed = 260.0
	jump_force = -480.0
	punch_damage = 9.0
	kick_damage = 11.0
	special_damage = 26.0
	special_name = "Operation Lone Star"
	super._ready()


func get_catchphrase() -> String:
	return "This stage is CLOSED."


func attack(type: String, damage: float) -> void:
	if type == "kick":
		_place_barrier()
	await super.attack(type, damage)


func _place_barrier() -> void:
	# Clean up destroyed barriers
	barriers = barriers.filter(func(b): return is_instance_valid(b))

	if barriers.size() >= MAX_BARRIERS:
		var oldest = barriers.pop_front()
		oldest.queue_free()

	var barrier = Barrier.new()
	barrier.owner_fighter = self
	barrier.position = global_position + Vector2(60.0 if facing_right else -60.0, 0)
	get_parent().add_child(barrier)
	barriers.append(barrier)


func _is_behind_barrier() -> bool:
	for barrier in barriers:
		if not is_instance_valid(barrier):
			continue
		# Check if barrier is between Greg and opponent
		if opponent:
			var barrier_x = barrier.global_position.x
			var greg_x = global_position.x
			var opp_x = opponent.global_position.x
			if (greg_x < barrier_x and barrier_x < opp_x) or \
			   (greg_x > barrier_x and barrier_x > opp_x):
				return true
	return false


func take_damage(amount: float, unblockable: bool = false) -> void:
	# "Pulled Up the Ladder" — 30% DR behind own barriers
	if _is_behind_barrier():
		amount *= BEHIND_BARRIER_DR
	super.take_damage(amount, unblockable)


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# National Guard rush — 4 hits × 6.5 dmg, push toward barrier/wall
	if opponent:
		for i in range(4):
			opponent.take_damage(6.5, false)
			on_damage_dealt(6.5)
			var push_dir = 1.0 if opponent.global_position.x > global_position.x else -1.0
			opponent.apply_knockback(push_dir, 150.0)
			await get_tree().create_timer(0.2).timeout

		# Bonus if opponent hit a barrier
		for barrier in barriers:
			if is_instance_valid(barrier):
				if abs(opponent.global_position.x - barrier.global_position.x) < 40:
					opponent.take_damage(8.0, false)
					on_damage_dealt(8.0)
					break

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	for barrier in barriers:
		if is_instance_valid(barrier):
			barrier.queue_free()
	barriers.clear()
```

- [ ] **Step 3: Commit**

```bash
git add scripts/core/barrier.gd scripts/characters/greg_ablot.gd
git commit -m "feat: add Greg Ablot — trap specialist with destructible barriers"
```

---

### Task 8: Don the Con — Final Boss

**Files:**
- Create: `scripts/characters/don_the_con.gd`

- [ ] **Step 1: Create character script**

```gdscript
extends Fighter

## Don the Con — Unlockable Final Boss
## Special: "Executive Disorder" — Projectile rain that bans inputs
## Passive: "Fake It Till You Make It" — Faster taunt (0.5s)
## Ego Meter: At 100, Tremendous Mode (8s, 1.5x damage, super armor)
## Phase 2: At 40% HP, attack speed +20%, tweet projectiles every 3s

var ego_meter: float = 0.0
const EGO_MAX: float = 100.0
const EGO_ON_HIT: float = 5.0
const EGO_ON_TAUNT: float = 10.0

var tremendous_mode: bool = false
var _tremendous_timer: float = 0.0
const TREMENDOUS_DURATION: float = 8.0
const TREMENDOUS_DAMAGE_MULT: float = 1.5

var phase_2: bool = false
var _tweet_timer: float = 0.0
const TWEET_INTERVAL: float = 3.0
const TWEET_DAMAGE: float = 4.0
const TWEET_SPEED: float = 500.0

var fake_news_active: bool = false
var _tweet_from_left: bool = true


func _ready() -> void:
	fighter_name = "Don the Con"
	max_health = 160.0
	speed = 230.0
	jump_force = -460.0
	punch_damage = 12.0
	kick_damage = 14.0
	special_damage = 35.0
	special_name = "Executive Disorder"
	taunt_duration = 0.5  # "Fake It Till You Make It"
	secondary_resource_max = EGO_MAX
	super._ready()


func get_catchphrase() -> String:
	return "Nobody fights like me. Everybody says so. Tremendous fighter."


func passive_proc(delta: float) -> void:
	# Tremendous Mode timer
	if tremendous_mode:
		_tremendous_timer -= delta
		if _tremendous_timer <= 0:
			tremendous_mode = false

	# Phase 2 check
	if not phase_2 and health <= max_health * 0.4 and health > 0:
		_enter_phase_2()

	# Phase 2: tweet projectiles
	if phase_2:
		_tweet_timer += delta
		if _tweet_timer >= TWEET_INTERVAL:
			_tweet_timer = 0.0
			_fire_tweet()

	# Fake News check
	if not fake_news_active and health <= max_health * 0.25 and health > 0:
		fake_news_active = true
		passive_triggered.emit("FAKE NEWS")
		# TODO: Visual — obscure 20% of screen


func _enter_phase_2() -> void:
	phase_2 = true
	# Attack speed +20% — implemented via faster animation
	passive_triggered.emit("Phase 2 — You're Fired!")
	# TODO: Visual — stage transformation


func _fire_tweet() -> void:
	var proj = Projectile.new()
	proj.damage = TWEET_DAMAGE
	proj.speed = TWEET_SPEED
	proj.unblockable = false
	proj.owner_fighter = self
	if _tweet_from_left:
		proj.position = Vector2(-50, global_position.y - 30)
		proj.direction = 1.0
	else:
		proj.position = Vector2(1330, global_position.y - 30)  # Right side of 1280 stage
		proj.direction = -1.0
	_tweet_from_left = not _tweet_from_left
	get_parent().add_child(proj)


func on_hit_landed() -> void:
	super.on_hit_landed()
	ego_meter = min(ego_meter + EGO_ON_HIT, EGO_MAX)
	set_secondary_resource(ego_meter)
	_check_tremendous()


func on_taunt_complete() -> void:
	ego_meter = min(ego_meter + EGO_ON_TAUNT, EGO_MAX)
	set_secondary_resource(ego_meter)
	_check_tremendous()


func _check_tremendous() -> void:
	if ego_meter >= EGO_MAX and not tremendous_mode:
		tremendous_mode = true
		_tremendous_timer = TREMENDOUS_DURATION
		passive_triggered.emit("TREMENDOUS MODE")


func get_effective_punch() -> float:
	var base = super.get_effective_punch()
	if tremendous_mode:
		base *= TREMENDOUS_DAMAGE_MULT
	return base


func get_effective_kick() -> float:
	var base = super.get_effective_kick()
	if tremendous_mode:
		base *= TREMENDOUS_DAMAGE_MULT
	return base


func take_damage(amount: float, unblockable: bool = false) -> void:
	if tremendous_mode:
		# Super armor — don't interrupt attacks
		ego_meter -= amount
		set_secondary_resource(max(ego_meter, 0.0))
	super.take_damage(amount, unblockable)


func use_special() -> void:
	if special_meter < 100.0:
		return
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	is_attacking = true

	# "Executive Disorder" — 7 projectiles, 5 dmg each, each bans an input
	var input_actions = ["left", "right", "up", "down", "punch", "kick", "special"]
	input_actions.shuffle()

	for i in range(7):
		var proj = spawn_projectile(5.0, 300.0, false)
		# TODO: On hit, ban the corresponding input for 5 seconds
		# proj.on_hit = func(target): input_manager.ban_input(...)
		await get_tree().create_timer(0.15).timeout

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	ego_meter = 0.0
	tremendous_mode = false
	_tremendous_timer = 0.0
	# Phase 2 and Fake News are HP-based — reset flags so they re-evaluate
	# against the new round's full HP (which will be above thresholds)
	phase_2 = false
	fake_news_active = false
	_tweet_timer = 0.0
	set_secondary_resource(0.0)
```

- [ ] **Step 2: Test in-engine**

Verify:
- Ego builds on hit and taunt
- Tremendous Mode triggers at 100 ego
- Phase 2 triggers at 40% HP
- Tweets fire every 3 seconds in Phase 2

- [ ] **Step 3: Commit**

```bash
git add scripts/characters/don_the_con.gd
git commit -m "feat: add Don the Con — final boss with Ego Meter and Phase 2"
```
