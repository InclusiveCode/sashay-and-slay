class_name BorderRunway
extends Stage

## The Border Runway — fashion runway on top of the border wall.
## Hazard: spotlight tracks a random fighter. After 3s exposure the target
## receives a "dazzle" debuff for 4s (30% attack whiff). Re-targets every 10s.


func _ready() -> void:
	stage_name = "The Border Runway"
	var hazard := SpotlightHazard.new()
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------
class SpotlightHazard extends StageHazard:

	var _target: Fighter = null
	var _exposure_timer: float = 0.0
	var _retarget_timer: float = 0.0
	const EXPOSURE_THRESHOLD: float = 3.0
	const RETARGET_INTERVAL: float = 10.0
	const DAZZLE_DURATION: float = 4.0

	func _ready() -> void:
		hazard_name = "Spotlight"
		# interval is unused — we manage timing manually
		interval = 9999.0

	func activate() -> void:
		pass  # All logic is handled in _physics_process override

	func _physics_process(delta: float) -> void:
		if not active or fighters.is_empty():
			return

		# Retarget on a separate timer
		_retarget_timer += delta
		if _retarget_timer >= RETARGET_INTERVAL or _target == null or not is_instance_valid(_target):
			_pick_target()
			_retarget_timer = 0.0
			_exposure_timer = 0.0

		# Track exposure while fighter is spotlit (always in spotlight if targeted)
		if _target != null and is_instance_valid(_target):
			_exposure_timer += delta
			if _exposure_timer >= EXPOSURE_THRESHOLD and not _target.get_meta("dazzled", false):
				_apply_dazzle(_target)

	func _pick_target() -> void:
		if fighters.is_empty():
			_target = null
			return
		var valid: Array[Fighter] = []
		for f in fighters:
			if is_instance_valid(f):
				valid.append(f)
		if valid.is_empty():
			_target = null
			return
		_target = valid[randi() % valid.size()]

	func _apply_dazzle(fighter: Fighter) -> void:
		fighter.set_meta("dazzled", true)
		# Mark dazzle active with duration tracked on a Timer node added to fighter
		var t := Timer.new()
		t.wait_time = DAZZLE_DURATION
		t.one_shot = true
		fighter.add_child(t)
		t.timeout.connect(func() -> void:
			if is_instance_valid(fighter):
				fighter.set_meta("dazzled", false)
			t.queue_free()
		)
		t.start()
