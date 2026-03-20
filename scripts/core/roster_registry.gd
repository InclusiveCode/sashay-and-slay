class_name RosterRegistry
extends RefCounted

## Central roster registry — maps fighter names to script paths, teams,
## catchphrases, and roles. Used by character select and fight setup.

const QUEENS: Dictionary = {
	"Valencia Thunderclap": {
		"script": "res://scripts/characters/valencia_thunderclap.gd",
		"team": "queens",
		"catchphrase": "You're giving me nothing to work with, and I'm still serving everything.",
		"role": "Counter-attacker",
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
		"role": "Rushdown Disruptor",
	},
	"Dixie Normous": {
		"script": "res://scripts/characters/dixie_normous.gd",
		"team": "queens",
		"catchphrase": "Oh honey, I'm not being mean. The truth just hurts when it's this well-accessorized.",
		"role": "Debuff Queen",
	},
	"Siren St. James": {
		"script": "res://scripts/characters/siren_st_james.gd",
		"team": "queens",
		"catchphrase": "I'd wish you luck, but it won't help.",
		"role": "Precision Striker",
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
		"role": "Zone Controller",
	},
	"Aurora Borealis": {
		"script": "res://scripts/characters/aurora_borealis.gd",
		"team": "queens",
		"catchphrase": "You tried to erase us from the sky. Look up.",
		"role": "Ranged Hybrid",
	},
}

const POLITICIANS: Dictionary = {
	"Ron DeSanctimonious": {
		"script": "res://scripts/characters/ron_desanctimonious.gd",
		"team": "politicians",
		"catchphrase": "This fight has been deemed inappropriate for all audiences.",
		"role": "Culture Warrior",
	},
	"Marjorie Trailer Queen": {
		"script": "res://scripts/characters/marjorie_trailer_queen.gd",
		"team": "politicians",
		"catchphrase": "I did my own research! On Facebook!",
		"role": "Unhinged Rushdown",
	},
	"Cancun Cruz": {
		"script": "res://scripts/characters/cancun_cruz.gd",
		"team": "politicians",
		"catchphrase": "I'd love to fight, but I have a flight to catch.",
		"role": "Coward Zoner",
	},
	"Moscow Mitch": {
		"script": "res://scripts/characters/moscow_mitch.gd",
		"team": "politicians",
		"catchphrase": "The motion to defeat me... is tabled.",
		"role": "Pure Tank",
	},
	"Elmo Musk": {
		"script": "res://scripts/characters/elmo_musk.gd",
		"team": "politicians",
		"catchphrase": "I'm not a villain. I'm a disruptor. Same thing.",
		"role": "Tech Bro",
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

const BOSS: Dictionary = {
	"Don the Con": {
		"script": "res://scripts/characters/don_the_con.gd",
		"team": "boss",
		"catchphrase": "Nobody fights like me. Everybody says so. Tremendous fighter.",
		"role": "Final Boss",
	},
}


## Returns the full roster for versus mode (queens + politicians + optionally boss).
static func get_versus_roster(don_unlocked: bool) -> Dictionary:
	var roster := {}
	roster.merge(QUEENS)
	roster.merge(POLITICIANS)
	if don_unlocked:
		roster.merge(BOSS)
	return roster


## Returns queens only (for arcade mode character select).
static func get_arcade_roster() -> Dictionary:
	return QUEENS.duplicate()


## Returns shuffled array of politician names for arcade opponent queue.
static func get_arcade_opponents() -> Array:
	var opponents: Array = POLITICIANS.keys()
	opponents.shuffle()
	return opponents


## Instantiates a Fighter from the roster by name.
static func create_fighter(fighter_name: String) -> Fighter:
	var all_fighters := {}
	all_fighters.merge(QUEENS)
	all_fighters.merge(POLITICIANS)
	all_fighters.merge(BOSS)

	if fighter_name not in all_fighters:
		push_error("RosterRegistry: Unknown fighter '%s'" % fighter_name)
		return null

	var entry: Dictionary = all_fighters[fighter_name]
	var script: GDScript = load(entry["script"])
	var fighter: Fighter = script.new()
	return fighter
