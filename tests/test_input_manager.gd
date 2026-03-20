extends GutTest

## Tests for InputManager: scramble, ban, silence, clear, eviction.

var im: InputManager


func before_each() -> void:
	im = InputManager.new()
	add_child(im)


func after_each() -> void:
	im.queue_free()


# --- Passthrough ---

func test_passthrough_no_effects() -> void:
	assert_eq(im.get_remapped_action("p1_punch", true), "p1_punch",
		"With no scrambles, action should pass through unchanged")
	assert_false(im.is_input_banned("p1_punch"),
		"With no bans, action should not be banned")


# --- Scramble ---

func test_scramble_remaps_action() -> void:
	im.scramble_input("p1_", "punch", "kick", 10.0)
	var result := im.get_remapped_action("p1_punch", true)
	assert_eq(result, "p1_kick",
		"Scrambled punch should remap to kick")


func test_scramble_does_not_affect_other_actions() -> void:
	im.scramble_input("p1_", "punch", "kick", 10.0)
	assert_eq(im.get_remapped_action("p1_kick", true), "p1_kick",
		"Non-scrambled action should pass through")


func test_scramble_does_not_affect_other_player() -> void:
	im.scramble_input("p1_", "punch", "kick", 10.0)
	assert_eq(im.get_remapped_action("p2_punch", true), "p2_punch",
		"Other player should not be affected by scramble")


# --- Ban ---

func test_ban_blocks_action() -> void:
	im.ban_input("p1_", "punch", 10.0)
	assert_true(im.is_input_banned("p1_punch"),
		"Banned action should be reported as banned")


func test_ban_does_not_affect_other_actions() -> void:
	im.ban_input("p1_", "punch", 10.0)
	assert_false(im.is_input_banned("p1_kick"),
		"Non-banned action should not be banned")


func test_active_ban_count() -> void:
	im.ban_input("p1_", "punch", 10.0)
	im.ban_input("p1_", "kick", 10.0)
	assert_eq(im.get_active_ban_count("p1_"), 2,
		"Should count 2 active bans for p1_")
	assert_eq(im.get_active_ban_count("p2_"), 0,
		"Should count 0 bans for p2_")


# --- Silence ---

func test_silence_bans_attack_actions() -> void:
	im.silence_player("p1_", 10.0)
	assert_true(im.is_input_banned("p1_punch"), "Silence should ban punch")
	assert_true(im.is_input_banned("p1_kick"), "Silence should ban kick")
	assert_true(im.is_input_banned("p1_special"), "Silence should ban special")
	assert_true(im.is_input_banned("p1_down"), "Silence should ban down/block")
	assert_true(im.is_input_banned("p1_taunt"), "Silence should ban taunt")


func test_silence_does_not_ban_movement() -> void:
	im.silence_player("p1_", 10.0)
	assert_false(im.is_input_banned("p1_left"), "Silence should NOT ban left")
	assert_false(im.is_input_banned("p1_right"), "Silence should NOT ban right")
	assert_false(im.is_input_banned("p1_up"), "Silence should NOT ban up/jump")


# --- Clear ---

func test_clear_all_removes_effects() -> void:
	im.scramble_input("p1_", "punch", "kick", 10.0)
	im.ban_input("p1_", "special", 10.0)
	im.clear_all("p1_")
	assert_eq(im.get_remapped_action("p1_punch", true), "p1_punch",
		"Clear should remove scrambles")
	assert_false(im.is_input_banned("p1_special"),
		"Clear should remove bans")


func test_clear_all_does_not_affect_other_player() -> void:
	im.ban_input("p1_", "punch", 10.0)
	im.ban_input("p2_", "punch", 10.0)
	im.clear_all("p1_")
	assert_false(im.is_input_banned("p1_punch"),
		"P1 ban should be cleared")
	assert_true(im.is_input_banned("p2_punch"),
		"P2 ban should remain")


# --- Evict oldest ban ---

func test_evict_oldest_ban() -> void:
	# Ban punch first (shorter duration = earlier expiry = oldest)
	im.ban_input("p1_", "punch", 1.0)
	im.ban_input("p1_", "kick", 10.0)
	im.evict_oldest_ban("p1_")
	assert_false(im.is_input_banned("p1_punch"),
		"Oldest ban (punch) should be evicted")
	assert_true(im.is_input_banned("p1_kick"),
		"Newer ban (kick) should remain")


func test_evict_oldest_ban_empty_prefix() -> void:
	# Should not crash when no bans exist
	im.evict_oldest_ban("p1_")
	assert_eq(im.get_active_ban_count("p1_"), 0)
