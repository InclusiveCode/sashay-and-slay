class_name FiliBusterLounge
extends Stage

## The Fili-Buster Lounge — velvet nightclub inside the Senate chamber.
## Hazard: bass drop every 30s launches both fighters airborne (no damage).


func _ready() -> void:
	stage_name = "The Fili-Buster Lounge"
	var hazard := BassDrop.new()
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------
class BassDrop extends StageHazard:

	func _ready() -> void:
		hazard_name = "Bass Drop"
		interval = 30.0

	func activate() -> void:
		# Launch only — no damage
		for fighter in fighters:
			if is_instance_valid(fighter):
				fighter.velocity.y = -500.0
