class_name PrideFloatOfWar
extends Stage

## Pride Float of War — massive pride parade float rolling through D.C.
## Hazard: every 15s the float turns a corner — 2s momentum push applies
## 100px of force toward a random direction each frame for the duration.


func _ready() -> void:
	stage_name = "Pride Float of War"
	var hazard := FloatMomentumHazard.new()
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------
class FloatMomentumHazard extends StageHazard:

	const PUSH_DURATION: float = 2.0
	const PUSH_FORCE: float = 100.0

	var _push_active: bool = false
	var _push_timer: float = 0.0
	var _push_direction: float = 1.0  # +1 = right, -1 = left

	func _ready() -> void:
		hazard_name = "Float Momentum"
		interval = 15.0

	func _physics_process(delta: float) -> void:
		if not active:
			return

		if _push_active:
			_push_timer += delta
			_apply_push(delta)
			if _push_timer >= PUSH_DURATION:
				_push_active = false
				_push_timer = 0.0
			return

		super._physics_process(delta)

	func activate() -> void:
		_push_active = true
		_push_timer = 0.0
		_push_direction = 1.0 if randi() % 2 == 0 else -1.0

	func _apply_push(delta: float) -> void:
		for fighter in fighters:
			if is_instance_valid(fighter):
				fighter.velocity.x += _push_direction * PUSH_FORCE * delta
