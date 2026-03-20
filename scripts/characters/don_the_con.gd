class_name DonTheCon
extends Fighter

## Final Boss — Overpowered with Ego Meter, Tremendous Mode, phase transitions,
## and tweet projectile spam. Unlocked after completing arcade mode.

# Ego Meter
const EGO_MAX: float = 100.0
const EGO_PER_HIT: float = 5.0
const EGO_PER_TAUNT: float = 10.0

# Tremendous Mode
var _tremendous_mode: bool = false
var _tremendous_timer: float = 0.0
const TREMENDOUS_DURATION: float = 8.0
const TREMENDOUS_MULTIPLIER: float = 1.5

# Phase 2
var _phase_2_active: bool = false
var _tweet_timer: float = 0.0
const TWEET_INTERVAL: float = 3.0
const TWEET_DAMAGE: float = 4.0
const TWEET_SPEED: float = 500.0
var _tweet_from_left: bool = true

# Fake News
var fake_news_active: bool = false


func _ready() -> void:
	fighter_name = "Don the Con"
	max_health = 160.0
	speed = 230.0
	jump_force = -460.0
	punch_damage = 12.0
	kick_damage = 14.0
	special_damage = 35.0
	special_name = "Executive Disorder"
	secondary_resource_max = EGO_MAX
	taunt_duration = 0.5  # "Fake It Till You Make It" — faster taunt
	super._ready()


func get_catchphrase() -> String:
	return "Nobody fights like me. Everybody says so. Tremendous fighter."


func on_hit_landed() -> void:
	super.on_hit_landed()
	# Build ego on landing hits
	set_secondary_resource(secondary_resource + EGO_PER_HIT)
	_check_tremendous()


func on_taunt_complete() -> void:
	# Build ego on taunt
	set_secondary_resource(secondary_resource + EGO_PER_TAUNT)
	_check_tremendous()


func _check_tremendous() -> void:
	if secondary_resource >= EGO_MAX and not _tremendous_mode:
		_tremendous_mode = true
		_tremendous_timer = TREMENDOUS_DURATION
		passive_triggered.emit("Tremendous Mode")


func get_effective_punch() -> float:
	var base := super.get_effective_punch()
	if _tremendous_mode:
		return base * TREMENDOUS_MULTIPLIER
	return base


func get_effective_kick() -> float:
	var base := super.get_effective_kick()
	if _tremendous_mode:
		return base * TREMENDOUS_MULTIPLIER
	return base


func take_damage(amount: float, unblockable: bool = false) -> void:
	# Super armor during Tremendous Mode — take damage but don't flinch
	# (velocity not affected, is_attacking not interrupted)
	super.take_damage(amount, unblockable)

	# Drain ego by damage amount during Tremendous Mode
	if _tremendous_mode:
		set_secondary_resource(secondary_resource - amount)

	# Phase 2 trigger at 40% HP
	if not _phase_2_active and health <= max_health * 0.4:
		_phase_2_active = true
		_tweet_timer = TWEET_INTERVAL
		passive_triggered.emit("Phase 2 — You're Fired!")

	# Fake News trigger at 25% HP
	if not fake_news_active and health <= max_health * 0.25:
		fake_news_active = true
		passive_triggered.emit("Fake News")


func passive_proc(delta: float) -> void:
	# Tremendous Mode timer
	if _tremendous_mode:
		_tremendous_timer -= delta
		if _tremendous_timer <= 0.0:
			_tremendous_mode = false
			_tremendous_timer = 0.0
			# Don't reset ego here — it was drained by damage.
			# Player must rebuild to 100 for next activation.

	# Phase 2 tweet spam
	if _phase_2_active:
		_tweet_timer -= delta
		if _tweet_timer <= 0.0:
			_tweet_timer = TWEET_INTERVAL
			_fire_tweet()


func _fire_tweet() -> void:
	var proj := Projectile.new()
	proj.damage = TWEET_DAMAGE
	proj.speed = TWEET_SPEED
	proj.unblockable = false
	proj.owner_fighter = self

	if _tweet_from_left:
		proj.position = Vector2(ARENA_LEFT, position.y - 20.0)
		proj.direction = 1.0
	else:
		proj.position = Vector2(ARENA_RIGHT, position.y - 20.0)
		proj.direction = -1.0

	_tweet_from_left = not _tweet_from_left
	get_tree().current_scene.add_child(proj)


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# 7 projectiles, 5 dmg each
	for i in range(7):
		var proj := spawn_projectile(5.0, 400.0, false)
		# Spread projectiles slightly in Y
		proj.position.y += (i - 3) * 15.0

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


## Phase 2 attack speed boost — override to apply 20% faster attacks
func attack(type: String, damage: float) -> void:
	is_attacking = true
	on_damage_dealt(damage)
	on_hit_landed()
	if anim_player:
		anim_player.play(type)
		if _phase_2_active:
			anim_player.speed_scale = 1.2
		await anim_player.animation_finished
		anim_player.speed_scale = 1.0
	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	set_secondary_resource(0.0)
	_tremendous_mode = false
	_tremendous_timer = 0.0
	_phase_2_active = false
	_tweet_timer = 0.0
	_tweet_from_left = true
	fake_news_active = false
	taunt_duration = 0.5
