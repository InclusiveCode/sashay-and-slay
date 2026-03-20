# Plan 5: Game Flow — Arcade Mode, Character Select, Fight Wiring

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire everything together: update character select with the new roster, connect the fight scene to load actual fighters, implement arcade mode progression, victory screens, and the Don the Con unlock system.

**Architecture:** GameManager drives the game flow. Character select populates from a roster registry. Fight scene instantiates fighters and connects them to HUD signals. Arcade mode tracks progression through a queue of opponents.

**Tech Stack:** Godot 4.2, GDScript

**Spec:** `docs/superpowers/specs/2026-03-20-character-and-stage-redesign.md`
**Depends on:** Plans 1-4 (all fighters, stages, and core systems must exist)

---

### File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `scripts/core/roster_registry.gd` | Central roster of all fighters with metadata |
| Modify | `scripts/ui/character_select.gd` | Update to use new roster, arcade mode queen-only select |
| Modify | `scripts/ui/main_menu.gd` | Add arcade mode button |
| Modify | `scenes/ui/main_menu.tscn` | Add arcade mode button to layout |
| Create | `scripts/core/fight_manager.gd` | Manages fight scene — loads fighters, connects signals, handles rounds |
| Modify | `scenes/fight.tscn` | Wire FightManager, connect HUD |
| Create | `scripts/ui/victory_screen.gd` | Post-match victory/defeat screen |
| Create | `scenes/ui/victory_screen.tscn` | Victory screen scene |
| Create | `scripts/core/arcade_manager.gd` | Manages arcade mode progression |
| Modify | `scripts/core/game_manager.gd` | Add arcade mode state, unlock persistence |

---

### Task 1: Roster Registry

**Files:**
- Create: `scripts/core/roster_registry.gd`

- [ ] **Step 1: Create roster registry**

```gdscript
class_name RosterRegistry
extends RefCounted

## Central roster of all playable fighters.

const QUEENS = {
	"Valencia Thunderclap": {
		"script": "res://scripts/characters/valencia_thunderclap.gd",
		"team": "queens",
		"catchphrase": "You're giving me nothing to work with, and I'm still serving everything.",
		"role": "Counter/Evasion",
	},
	"Mama Molotov": {
		"script": "res://scripts/characters/mama_molotov.gd",
		"team": "queens",
		"catchphrase": "I've been fighting fascists since before you were a fundraising email.",
		"role": "Rage Tank",
	},
	"Anita Riot": {
		"script": "res://scripts/characters/anita_riot.gd",
		"team": "queens",
		"catchphrase": "Your comfort was built on our silence. Sound check's over.",
		"role": "Rushdown/Disrupt",
	},
	"Dixie Normous": {
		"script": "res://scripts/characters/dixie_normous.gd",
		"team": "queens",
		"catchphrase": "Oh honey, I'm not being mean. The truth just hurts when it's this well-accessorized.",
		"role": "Debuffer",
	},
	"Siren St. James": {
		"script": "res://scripts/characters/siren_st_james.gd",
		"team": "queens",
		"catchphrase": "I'd wish you luck, but it won't help.",
		"role": "Precision",
	},
	"Rex Hazard": {
		"script": "res://scripts/characters/rex_hazard.gd",
		"team": "queens",
		"catchphrase": "I'm not your daddy. But I am your problem.",
		"role": "Grappler",
	},
	"Thornia Rose": {
		"script": "res://scripts/characters/thornia_rose.gd",
		"team": "queens",
		"catchphrase": "Nature doesn't negotiate. Neither do I.",
		"role": "Zone Control",
	},
	"Aurora Borealis": {
		"script": "res://scripts/characters/aurora_borealis.gd",
		"team": "queens",
		"catchphrase": "You tried to erase us from the sky. Look up.",
		"role": "Ranged/Sustain",
	},
}

const POLITICIANS = {
	"Ron DeSanctimonious": {
		"script": "res://scripts/characters/ron_desanctimonious.gd",
		"team": "politicians",
		"catchphrase": "This fight has been deemed inappropriate for all audiences.",
		"role": "Move Denial",
	},
	"Marjorie Trailer Queen": {
		"script": "res://scripts/characters/marjorie_trailer_queen.gd",
		"team": "politicians",
		"catchphrase": "I did my own research! On Facebook!",
		"role": "Chaotic Rushdown",
	},
	"Cancun Cruz": {
		"script": "res://scripts/characters/cancun_cruz.gd",
		"team": "politicians",
		"catchphrase": "I'd love to fight, but I have a flight to catch.",
		"role": "Zoner/Coward",
	},
	"Moscow Mitch": {
		"script": "res://scripts/characters/moscow_mitch.gd",
		"team": "politicians",
		"catchphrase": "The motion to defeat me... is tabled.",
		"role": "Stall Tank",
	},
	"Elmo Musk": {
		"script": "res://scripts/characters/elmo_musk.gd",
		"team": "politicians",
		"catchphrase": "I'm not a villain. I'm a disruptor. Same thing.",
		"role": "Gadget/Resource",
	},
	"Mike Dense": {
		"script": "res://scripts/characters/mike_dense.gd",
		"team": "politicians",
		"catchphrase": "Mother wouldn't approve of this.",
		"role": "Holy Warrior",
	},
	"Greg Ablot": {
		"script": "res://scripts/characters/greg_ablot.gd",
		"team": "politicians",
		"catchphrase": "This stage is CLOSED.",
		"role": "Trap Specialist",
	},
}

const BOSS = {
	"Don the Con": {
		"script": "res://scripts/characters/don_the_con.gd",
		"team": "boss",
		"catchphrase": "Nobody fights like me. Everybody says so. Tremendous fighter.",
		"role": "Final Boss",
	},
}


static func get_versus_roster(don_unlocked: bool) -> Dictionary:
	var roster = {}
	roster.merge(QUEENS)
	roster.merge(POLITICIANS)
	if don_unlocked:
		roster.merge(BOSS)
	return roster


static func get_arcade_roster() -> Dictionary:
	return QUEENS.duplicate()


static func get_arcade_opponents() -> Array:
	var opponents = POLITICIANS.keys()
	opponents.shuffle()
	return opponents


static func create_fighter(fighter_name: String) -> Fighter:
	var all = {}
	all.merge(QUEENS)
	all.merge(POLITICIANS)
	all.merge(BOSS)
	if fighter_name not in all:
		return null
	var script = load(all[fighter_name]["script"])
	var fighter = Fighter.new()
	fighter.set_script(script)
	return fighter
```

- [ ] **Step 2: Commit**

```bash
git add scripts/core/roster_registry.gd
git commit -m "feat: add RosterRegistry — central roster with fighter metadata"
```

---

### Task 2: Update Character Select

**Files:**
- Modify: `scripts/ui/character_select.gd`

- [ ] **Step 1: Replace hardcoded roster with RosterRegistry**

Replace the existing `ROSTER` dictionary and `_build_roster_grid()` in `scripts/ui/character_select.gd`:

```gdscript
extends Control

var p1_character: String = ""
var p2_character: String = ""
var is_arcade_mode: bool = false

@onready var grid: GridContainer = $GridContainer
@onready var title_label: Label = $Title


func _ready() -> void:
	is_arcade_mode = GameManager.current_mode == "arcade"
	if is_arcade_mode:
		title_label.text = "CHOOSE YOUR QUEEN"
	else:
		title_label.text = "CHOOSE YOUR FIGHTER"
	_build_roster_grid()


func _build_roster_grid() -> void:
	for child in grid.get_children():
		child.queue_free()

	var roster: Dictionary
	if is_arcade_mode:
		roster = RosterRegistry.get_arcade_roster()
	else:
		roster = RosterRegistry.get_versus_roster(GameManager.don_unlocked)

	for fighter_name in roster:
		var entry = roster[fighter_name]
		var btn = Button.new()
		btn.text = fighter_name + "\n" + entry["role"]
		btn.custom_minimum_size = Vector2(200, 80)
		btn.pressed.connect(_on_character_button_pressed.bind(fighter_name))

		# Color code by team
		if entry["team"] == "queens":
			btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.8))
		elif entry["team"] == "politicians":
			btn.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		elif entry["team"] == "boss":
			btn.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))

		grid.add_child(btn)


func _on_character_button_pressed(fighter_name: String) -> void:
	if p1_character == "":
		p1_character = fighter_name
	elif p2_character == "" and not is_arcade_mode:
		p2_character = fighter_name

	if is_arcade_mode and p1_character != "":
		# In arcade mode, go straight to fight
		GameManager.p1_character = p1_character
		_start_arcade()
	elif p1_character != "" and p2_character != "":
		GameManager.p1_character = p1_character
		GameManager.p2_character = p2_character
		_start_versus()


func _start_versus() -> void:
	get_tree().change_scene_to_file("res://scenes/fight.tscn")


func _start_arcade() -> void:
	GameManager.start_arcade_mode(p1_character)
	get_tree().change_scene_to_file("res://scenes/fight.tscn")
```

- [ ] **Step 2: Commit**

```bash
git add scripts/ui/character_select.gd
git commit -m "feat: update character select for new roster and arcade mode"
```

---

### Task 3: Update Main Menu

**Files:**
- Modify: `scripts/ui/main_menu.gd`
- Modify: `scenes/ui/main_menu.tscn`

- [ ] **Step 1: Add arcade mode button**

In `scripts/ui/main_menu.gd`, update the button handlers:

```gdscript
extends Control

@onready var versus_button: Button = $VBoxContainer/VersusButton
@onready var arcade_button: Button = $VBoxContainer/ArcadeButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	versus_button.pressed.connect(_on_versus)
	arcade_button.pressed.connect(_on_arcade)
	quit_button.pressed.connect(_on_quit)


func _on_versus() -> void:
	GameManager.current_mode = "versus"
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")


func _on_arcade() -> void:
	GameManager.current_mode = "arcade"
	get_tree().change_scene_to_file("res://scenes/ui/character_select.tscn")


func _on_quit() -> void:
	get_tree().quit()
```

- [ ] **Step 2: Update main_menu.tscn**

Add the ArcadeButton node to the VBoxContainer, between FightButton (rename to VersusButton) and QuitButton. Rename FightButton to VersusButton. Add ArcadeButton with text "ARCADE MODE".

- [ ] **Step 3: Commit**

```bash
git add scripts/ui/main_menu.gd scenes/ui/main_menu.tscn
git commit -m "feat: add arcade mode button to main menu"
```

---

### Task 4: Arcade Manager

**Files:**
- Create: `scripts/core/arcade_manager.gd`
- Modify: `scripts/core/game_manager.gd`

- [ ] **Step 1: Create ArcadeManager**

```gdscript
class_name ArcadeManager
extends RefCounted

## Manages arcade mode progression — tracks opponent queue and current fight.

var queen_name: String = ""
var opponent_queue: Array = []  # Fighter names in random order
var current_opponent_index: int = 0
var is_active: bool = false


func start(selected_queen: String) -> void:
	queen_name = selected_queen
	opponent_queue = RosterRegistry.get_arcade_opponents()
	current_opponent_index = 0
	is_active = true


func get_current_opponent() -> String:
	if current_opponent_index >= opponent_queue.size():
		return "Don the Con"  # Final boss
	return opponent_queue[current_opponent_index]


func get_current_stage() -> String:
	var opponent = get_current_opponent()
	return StageRegistry.get_stage_for_fighter(opponent)


func is_boss_fight() -> bool:
	return current_opponent_index >= opponent_queue.size()


func advance() -> void:
	current_opponent_index += 1


func is_complete() -> bool:
	# Complete after beating Don the Con (index = opponent_queue.size() + 1)
	return current_opponent_index > opponent_queue.size()


func get_progress_text() -> String:
	if is_boss_fight():
		return "FINAL BOSS"
	return "Fight %d of %d" % [current_opponent_index + 1, opponent_queue.size()]
```

- [ ] **Step 2: Add arcade support to GameManager**

In `scripts/core/game_manager.gd`, add:

```gdscript
var current_mode: String = "versus"  # "versus" or "arcade"
var p1_character: String = ""
var p2_character: String = ""
var arcade: ArcadeManager = ArcadeManager.new()

func start_arcade_mode(queen_name: String) -> void:
	current_mode = "arcade"
	p1_character = queen_name
	arcade.start(queen_name)
	p2_character = arcade.get_current_opponent()

func arcade_advance() -> void:
	arcade.advance()
	if arcade.is_complete():
		# Player beat Don the Con!
		don_unlocked = true
		_save_unlock()
	else:
		p2_character = arcade.get_current_opponent()

func _save_unlock() -> void:
	var config = ConfigFile.new()
	config.set_value("save", "don_unlocked", true)
	config.save("user://save.cfg")

func _load_unlock() -> void:
	var config = ConfigFile.new()
	if config.load("user://save.cfg") == OK:
		don_unlocked = config.get_value("save", "don_unlocked", false)
```

Add `_load_unlock()` call to GameManager's `_ready()`.

- [ ] **Step 3: Commit**

```bash
git add scripts/core/arcade_manager.gd scripts/core/game_manager.gd
git commit -m "feat: add ArcadeManager — tracks progression through opponent queue"
```

---

### Task 5: Fight Manager — Wire Fighters to Scene

**Files:**
- Create: `scripts/core/fight_manager.gd`
- Modify: `scenes/fight.tscn`

- [ ] **Step 1: Create FightManager**

```gdscript
extends Node

## FightManager — loads fighters into the fight scene, connects HUD signals,
## manages round flow, and handles match completion.

@onready var hud = $"../HUD"
@onready var stage_node = $"../Stage"

var p1_fighter: Fighter = null
var p2_fighter: Fighter = null
var current_stage: Stage = null


func _ready() -> void:
	_setup_input_manager()
	_load_fighters()
	_load_stage()
	_connect_signals()
	GameManager.start_round()


func _setup_input_manager() -> void:
	GameManager.setup_input_manager()


func _load_fighters() -> void:
	# Create P1 fighter
	p1_fighter = RosterRegistry.create_fighter(GameManager.p1_character)
	if p1_fighter:
		p1_fighter.is_player_one = true
		p1_fighter.position = Vector2(300, 550)
		p1_fighter.facing_right = true
		add_child(p1_fighter)
		GameManager.register_fighter(p1_fighter)

	# Create P2 fighter
	p2_fighter = RosterRegistry.create_fighter(GameManager.p2_character)
	if p2_fighter:
		p2_fighter.is_player_one = false
		p2_fighter.position = Vector2(980, 550)
		p2_fighter.facing_right = false
		add_child(p2_fighter)
		GameManager.register_fighter(p2_fighter)

	# Set opponent references
	if p1_fighter and p2_fighter:
		p1_fighter.opponent = p2_fighter
		p2_fighter.opponent = p1_fighter


func _load_stage() -> void:
	var stage_key: String
	if GameManager.current_mode == "arcade":
		stage_key = GameManager.arcade.get_current_stage()
	else:
		# Versus mode — random stage or let players choose
		var all_stages = StageRegistry.get_all_stage_names()
		stage_key = all_stages[randi() % all_stages.size()]

	var stage_script = load(StageRegistry.STAGE_SCRIPTS[stage_key])
	if stage_script:
		current_stage = Stage.new()
		current_stage.set_script(stage_script)
		if p1_fighter and p2_fighter:
			current_stage.set_fighters([p1_fighter, p2_fighter])
		stage_node.add_child(current_stage)

		# Boss stage special setup
		if stage_key == "gilded_throne_room" and p2_fighter:
			current_stage.set_boss(p2_fighter)


func _connect_signals() -> void:
	if p1_fighter:
		p1_fighter.health_changed.connect(func(h): hud.update_health(1, h, p1_fighter.max_health))
		p1_fighter.special_meter_changed.connect(func(s): hud.update_special(1, s))
		p1_fighter.defeated.connect(_on_fighter_defeated.bind(2))  # P2 wins
		if p1_fighter.secondary_resource_max > 0:
			p1_fighter.secondary_resource_changed.connect(func(v): hud.update_secondary(1, v))
			hud.setup_secondary_meter(1, p1_fighter.fighter_name, p1_fighter.secondary_resource_max)

	if p2_fighter:
		p2_fighter.health_changed.connect(func(h): hud.update_health(2, h, p2_fighter.max_health))
		p2_fighter.special_meter_changed.connect(func(s): hud.update_special(2, s))
		p2_fighter.defeated.connect(_on_fighter_defeated.bind(1))  # P1 wins
		if p2_fighter.secondary_resource_max > 0:
			p2_fighter.secondary_resource_changed.connect(func(v): hud.update_secondary(2, v))
			hud.setup_secondary_meter(2, p2_fighter.fighter_name, p2_fighter.secondary_resource_max)

	# Initial HUD state
	if p1_fighter:
		hud.update_health(1, p1_fighter.max_health, p1_fighter.max_health)
	if p2_fighter:
		hud.update_health(2, p2_fighter.max_health, p2_fighter.max_health)


func _on_fighter_defeated(winner: int) -> void:
	GameManager.end_round(winner)

	if GameManager.state == GameManager.State.MATCH_END:
		_on_match_end(winner)
	else:
		# Next round
		GameManager.broadcast_round_reset()
		_connect_signals()  # Reconnect with fresh HP
		hud.show_announcement("Round %d!" % GameManager.current_round)
		GameManager.start_round()


func _on_match_end(winner: int) -> void:
	if GameManager.current_mode == "arcade":
		if winner == 1:
			# Player won — advance arcade
			GameManager.arcade_advance()
			if GameManager.arcade.is_complete():
				# Beat the whole game!
				_show_victory("arcade_complete")
			else:
				# Show brief victory, then next fight
				hud.show_announcement("SLAY!")
				await get_tree().create_timer(2.0).timeout
				get_tree().change_scene_to_file("res://scenes/fight.tscn")
		else:
			# Player lost arcade mode
			_show_victory("arcade_defeat")
	else:
		# Versus mode
		var winner_name = GameManager.p1_character if winner == 1 else GameManager.p2_character
		_show_victory("versus", winner_name)


func _show_victory(mode: String, winner_name: String = "") -> void:
	GameManager.victory_mode = mode
	GameManager.victory_winner = winner_name
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")
```

- [ ] **Step 2: Add FightManager to fight.tscn**

In `scenes/fight.tscn`, add a Node child called "FightManager" with the script `scripts/core/fight_manager.gd`.

- [ ] **Step 3: Commit**

```bash
git add scripts/core/fight_manager.gd scenes/fight.tscn
git commit -m "feat: add FightManager — loads fighters, wires HUD, handles rounds"
```

---

### Task 6: Victory Screen

**Files:**
- Create: `scripts/ui/victory_screen.gd`
- Create: `scenes/ui/victory_screen.tscn`

- [ ] **Step 1: Create victory screen script**

```gdscript
extends Control

## Post-match screen — shows winner, catchphrase, and options.

@onready var title_label: Label = $VBoxContainer/Title
@onready var catchphrase_label: Label = $VBoxContainer/Catchphrase
@onready var continue_button: Button = $VBoxContainer/ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue)

	match GameManager.victory_mode:
		"versus":
			var winner = GameManager.victory_winner
			title_label.text = winner + " WINS!"
			var roster = RosterRegistry.get_versus_roster(true)
			if winner in roster:
				catchphrase_label.text = '"' + roster[winner]["catchphrase"] + '"'
			continue_button.text = "BACK TO MENU"

		"arcade_complete":
			title_label.text = "YOU DEFEATED THEM ALL!"
			var queen = GameManager.arcade.queen_name
			var roster = RosterRegistry.QUEENS
			if queen in roster:
				catchphrase_label.text = '"' + roster[queen]["catchphrase"] + '"'
			continue_button.text = "Don the Con UNLOCKED!\nBACK TO MENU"

		"arcade_defeat":
			title_label.text = "DEFEATED..."
			catchphrase_label.text = "The fight continues. Try again."
			continue_button.text = "BACK TO MENU"


func _on_continue() -> void:
	GameManager.reset_to_menu()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
```

- [ ] **Step 2: Create victory_screen.tscn**

Create `scenes/ui/victory_screen.tscn` with:
- Root: Control (full rect)
- ColorRect background (dark, celebratory)
- VBoxContainer centered with:
  - Title (Label, large font)
  - Catchphrase (Label, italic)
  - ContinueButton (Button)

- [ ] **Step 3: Commit**

```bash
git add scripts/ui/victory_screen.gd scenes/ui/victory_screen.tscn
git commit -m "feat: add victory screen with catchphrase and arcade completion"
```

---

### Task 7: Final Integration — GameManager State Updates

**Files:**
- Modify: `scripts/core/game_manager.gd`

- [ ] **Step 1: Add missing state variables and methods**

Ensure GameManager has all required state:

```gdscript
# Add to game_manager.gd:
var victory_mode: String = ""
var victory_winner: String = ""
var current_round: int = 1
var p1_round_wins: int = 0
var p2_round_wins: int = 0

func end_round(winner: int) -> void:
	if winner == 1:
		p1_round_wins += 1
	else:
		p2_round_wins += 1

	if p1_round_wins >= ROUNDS_TO_WIN or p2_round_wins >= ROUNDS_TO_WIN:
		state = State.MATCH_END
	else:
		current_round += 1
		state = State.ROUND_END

func start_round() -> void:
	state = State.FIGHTING
	round_started.emit()

func reset_to_menu() -> void:
	state = State.MENU
	p1_character = ""
	p2_character = ""
	current_round = 1
	p1_round_wins = 0
	p2_round_wins = 0
	fighters.clear()
	if input_manager:
		input_manager.queue_free()
		input_manager = null
	arcade = ArcadeManager.new()
```

- [ ] **Step 2: Add taunt input mapping to project.godot**

Ensure taunt inputs are mapped:
- `p1_taunt`: T key
- `p2_taunt`: Numpad 0

- [ ] **Step 3: Final smoke test**

Run the game end-to-end:
1. Main menu → Versus Mode → Select two fighters → Fight loads → HUD updates → Round ends → Match ends → Victory screen
2. Main menu → Arcade Mode → Select queen → Fight 1 loads with correct stage → Win → Next fight auto-loads → Continue through all 7 → Boss fight → Win → Don unlocked → Victory screen
3. Return to main menu → Versus → Don the Con is now selectable

- [ ] **Step 4: Commit**

```bash
git add scripts/core/game_manager.gd project.godot
git commit -m "feat: complete game flow — versus, arcade, unlock, victory screens"
```

---

### Task 8: Update sashay-and-slay.md

**Files:**
- Modify: `sashay-and-slay.md`

- [ ] **Step 1: Update README with new roster and game info**

Replace the roster tables and add arcade mode documentation. Update the project structure to reflect new files. Remove completed items from the "Next Steps" checklist.

- [ ] **Step 2: Commit**

```bash
git add sashay-and-slay.md
git commit -m "docs: update README with new roster, stages, and arcade mode"
```
