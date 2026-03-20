class_name SupremelyCuntyCourt
extends Stage

## The Supremely Cunty Court — drag brunch on the Supreme Court steps.
## Hazard: gavel shockwave every 20s deals 5 dmg to all and launches upward.


func _ready() -> void:
	stage_name = "The Supremely Cunty Court"
	var hazard := GavelShockwave.new()
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------
class GavelShockwave extends StageHazard:

	func _ready() -> void:
		hazard_name = "Gavel Shockwave"
		interval = 20.0

	func activate() -> void:
		apply_damage_to_all(5.0)
		for fighter in fighters:
			if is_instance_valid(fighter):
				fighter.velocity.y = -400.0
