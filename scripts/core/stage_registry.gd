class_name StageRegistry
extends RefCounted

## Maps politician names to stage keys and stage keys to script paths.

const STAGE_MAP: Dictionary = {
	"Ron DeSanctimonious": "book_ban_bonfire",
	"Marjorie Trailer Queen": "supremely_cunty_court",
	"Cancun Cruz": "border_runway",
	"Moscow Mitch": "fili_buster_lounge",
	"Elmo Musk": "gerrymandered_gauntlet",
	"Mike Dense": "pray_away_the_slay",
	"Greg Ablot": "mar_a_lardo",
	"Don the Con": "gilded_throne_room",
}

const STAGE_SCRIPTS: Dictionary = {
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


## Returns the stage key for the given politician name, or "" if not found.
static func get_stage_for_fighter(name: String) -> String:
	return STAGE_MAP.get(name, "")


## Returns all registered stage keys.
static func get_all_stage_names() -> Array:
	return STAGE_SCRIPTS.keys()
