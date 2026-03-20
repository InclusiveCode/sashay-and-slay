extends GutTest

## Tests for the stat modifier system in Fighter.

var fighter: Fighter


func before_each() -> void:
	fighter = Fighter.new()
	fighter.punch_damage = 10.0
	fighter.kick_damage = 12.0
	fighter.speed = 300.0
	add_child(fighter)


func after_each() -> void:
	fighter.queue_free()


func test_initial_modifier_is_one() -> void:
	assert_eq(fighter.get_stat_modifier(), 1.0, "Initial stat modifier should be 1.0")


func test_single_reduction_applies_ten_percent() -> void:
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.9, 0.001,
		"One reduction should give 0.9 modifier")


func test_reductions_stack() -> void:
	fighter.apply_stat_reduction()
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.8, 0.001,
		"Two reductions should give 0.8 modifier")
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.7, 0.001,
		"Three reductions should give 0.7 modifier")


func test_modifier_caps_at_half() -> void:
	for i in range(10):
		fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.5, 0.001,
		"Modifier should cap at 0.5 minimum")


func test_five_reductions_hit_cap() -> void:
	for i in range(5):
		fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_stat_modifier(), 0.5, 0.001,
		"Five reductions should exactly hit the 0.5 cap")


func test_reset_clears_reductions() -> void:
	fighter.apply_stat_reduction()
	fighter.apply_stat_reduction()
	fighter.reset_round_state()
	assert_eq(fighter.get_stat_modifier(), 1.0,
		"Reset should clear all stat reductions")


func test_effective_punch_with_modifier() -> void:
	assert_almost_eq(fighter.get_effective_punch(), 10.0, 0.001,
		"Effective punch at 1.0 modifier")
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_effective_punch(), 9.0, 0.001,
		"Effective punch at 0.9 modifier")


func test_effective_kick_with_modifier() -> void:
	assert_almost_eq(fighter.get_effective_kick(), 12.0, 0.001,
		"Effective kick at 1.0 modifier")
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_effective_kick(), 10.8, 0.001,
		"Effective kick at 0.9 modifier")


func test_effective_speed_with_modifier() -> void:
	assert_almost_eq(fighter.get_effective_speed(), 300.0, 0.001,
		"Effective speed at 1.0 modifier")
	fighter.apply_stat_reduction()
	assert_almost_eq(fighter.get_effective_speed(), 270.0, 0.001,
		"Effective speed at 0.9 modifier")


func test_effective_speed_with_temp_modifier() -> void:
	fighter._temp_speed_modifier = 1.5
	assert_almost_eq(fighter.get_effective_speed(), 450.0, 0.001,
		"Effective speed should account for temp speed modifier")


func test_effective_speed_with_both_modifiers() -> void:
	fighter.apply_stat_reduction()  # 0.9
	fighter._temp_speed_modifier = 1.5
	assert_almost_eq(fighter.get_effective_speed(), 405.0, 0.001,
		"Effective speed should multiply both modifiers: 300 * 0.9 * 1.5")
