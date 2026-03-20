class_name PrayAwayTheSlay
extends Stage

## Pray Away the Slay — megachurch converted into a ballroom competition.
## Hazard: holy water sprinklers every 25s for 5s slow all fighters 30%.


func _ready() -> void:
	stage_name = "Pray Away the Slay"
	var hazard := HolyWaterSprinkler.new()
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------
class HolyWaterSprinkler extends StageHazard:

	const SPRAY_DURATION: float = 5.0
	const SLOW_MODIFIER: float = 0.7

	func _ready() -> void:
		hazard_name = "Holy Water Sprinkler"
		interval = 25.0

	func activate() -> void:
		for fighter in fighters:
			if is_instance_valid(fighter):
				fighter.apply_temp_speed(SLOW_MODIFIER, SPRAY_DURATION)
