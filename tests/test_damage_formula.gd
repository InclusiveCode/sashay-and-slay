extends GutTest

## Tests for damage formula, blocking, knockback, and meter building.

var fighter: Fighter


func before_each() -> void:
	fighter = Fighter.new()
	fighter.max_health = 100.0
	fighter.health = 100.0
	fighter.special_meter = 0.0
	add_child(fighter)


func after_each() -> void:
	fighter.queue_free()


# --- Damage ---

func test_normal_damage() -> void:
	fighter.take_damage(20.0)
	assert_almost_eq(fighter.health, 80.0, 0.001,
		"Should take full damage when not blocking")


func test_blocked_damage_reduced_80_percent() -> void:
	fighter.is_blocking = true
	fighter.take_damage(20.0)
	# 20 * 0.2 = 4 damage taken
	assert_almost_eq(fighter.health, 96.0, 0.001,
		"Blocked damage should be reduced by 80%")


func test_unblockable_ignores_block() -> void:
	fighter.is_blocking = true
	fighter.take_damage(20.0, true)
	assert_almost_eq(fighter.health, 80.0, 0.001,
		"Unblockable damage should ignore blocking")


func test_health_cannot_go_below_zero() -> void:
	fighter.take_damage(150.0)
	assert_eq(fighter.health, 0.0, "Health should not go below 0")


func test_defeated_signal_on_zero_health() -> void:
	watch_signals(fighter)
	fighter.take_damage(100.0)
	assert_signal_emitted(fighter, "defeated")


# --- Knockback ---

func test_knockback_modifier_standard_health() -> void:
	fighter.max_health = 100.0
	assert_almost_eq(fighter.get_knockback_modifier(), 1.0, 0.001,
		"100 HP fighter should have 1.0 knockback modifier")


func test_knockback_modifier_high_health() -> void:
	fighter.max_health = 200.0
	assert_almost_eq(fighter.get_knockback_modifier(), 0.5, 0.001,
		"200 HP fighter should have 0.5 knockback modifier (harder to knock)")


func test_knockback_modifier_low_health() -> void:
	fighter.max_health = 50.0
	assert_almost_eq(fighter.get_knockback_modifier(), 2.0, 0.001,
		"50 HP fighter should have 2.0 knockback modifier (easier to knock)")


func test_apply_knockback_adds_velocity() -> void:
	fighter.velocity.x = 0.0
	fighter.apply_knockback(1.0, 100.0)
	# 100 * (100/100) = 100
	assert_almost_eq(fighter.velocity.x, 100.0, 0.001,
		"Knockback should add to velocity.x")


func test_apply_knockback_direction() -> void:
	fighter.velocity.x = 0.0
	fighter.apply_knockback(-1.0, 100.0)
	assert_almost_eq(fighter.velocity.x, -100.0, 0.001,
		"Negative direction should knock left")


# --- Meter building from dealing damage ---

func test_on_damage_dealt_builds_meter() -> void:
	fighter.special_meter = 0.0
	fighter.on_damage_dealt(10.0)
	# 10 * 0.4 = 4
	assert_almost_eq(fighter.special_meter, 4.0, 0.001,
		"Dealing 10 damage should build 4.0 meter")


func test_on_damage_dealt_caps_at_100() -> void:
	fighter.special_meter = 99.0
	fighter.on_damage_dealt(50.0)
	assert_almost_eq(fighter.special_meter, 100.0, 0.001,
		"Meter should cap at 100")


func test_damage_dealt_signal_emitted() -> void:
	watch_signals(fighter)
	fighter.on_damage_dealt(15.0)
	assert_signal_emitted(fighter, "damage_dealt")


func test_meter_builds_from_taking_damage() -> void:
	fighter.special_meter = 0.0
	fighter.take_damage(20.0)
	# 20 * 0.5 = 10
	assert_almost_eq(fighter.special_meter, 10.0, 0.001,
		"Taking 20 damage should build 10.0 meter (defensive)")
