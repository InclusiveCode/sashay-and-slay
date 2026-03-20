class_name GerrymanderGauntlet
extends Stage

## Gerrymandered Gauntlet — the stage keeps changing shape.
## Hazard: layout redraws every 20s from 5 predefined platform layouts.
## 1s warning before swap. Fighters are pushed to safe ground if a wall
## would spawn on their position.


# 5 predefined platform layouts — each is an Array of Vector2 positions.
# These represent platform center points that the stage would instantiate
# as StaticBody2D platforms. The hazard records current layout index so
# GameManager / scene can read it and rebuild platforms accordingly.
const LAYOUTS: Array = [
	# Layout 0 — default wide open
	[Vector2(320, 450), Vector2(640, 350), Vector2(960, 450)],
	# Layout 1 — left-heavy
	[Vector2(200, 400), Vector2(400, 300), Vector2(700, 480), Vector2(1000, 380)],
	# Layout 2 — central tower
	[Vector2(640, 250), Vector2(400, 420), Vector2(880, 420)],
	# Layout 3 — scattered low
	[Vector2(200, 520), Vector2(500, 520), Vector2(800, 520), Vector2(1100, 520)],
	# Layout 4 — asymmetric
	[Vector2(150, 350), Vector2(550, 480), Vector2(900, 300), Vector2(1150, 460)],
]

## Current layout index — readable by the scene to build platforms.
var current_layout_index: int = 0


func _ready() -> void:
	stage_name = "Gerrymandered Gauntlet"
	var hazard := RedrawHazard.new()
	hazard.stage_ref = self
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------
class RedrawHazard extends StageHazard:

	const WARNING_DURATION: float = 1.0
	var stage_ref: GerrymanderGauntlet = null
	var _warning_active: bool = false
	var _warning_timer: float = 0.0

	func _ready() -> void:
		hazard_name = "Gerrymander Redraw"
		interval = 20.0

	func _physics_process(delta: float) -> void:
		if not active:
			return

		if _warning_active:
			_warning_timer += delta
			if _warning_timer >= WARNING_DURATION:
				_warning_active = false
				_warning_timer = 0.0
				_do_redraw()
			return

		# Normal interval tick
		super._physics_process(delta)

	func activate() -> void:
		# Start warning phase before the actual redraw
		_warning_active = true
		_warning_timer = 0.0
		# TODO: trigger visual warning flash

	func _do_redraw() -> void:
		if stage_ref == null:
			return

		# Pick a new layout (different from current)
		var next_index: int = stage_ref.current_layout_index
		while next_index == stage_ref.current_layout_index and GerrymanderGauntlet.LAYOUTS.size() > 1:
			next_index = randi() % GerrymanderGauntlet.LAYOUTS.size()
		stage_ref.current_layout_index = next_index

		_push_fighters_to_safety()

	func _push_fighters_to_safety() -> void:
		if stage_ref == null:
			return
		var layout: Array = GerrymanderGauntlet.LAYOUTS[stage_ref.current_layout_index]
		for fighter in fighters:
			if not is_instance_valid(fighter):
				continue
			# If fighter overlaps any platform x-range, push them right by 80px
			for plat_pos in layout:
				var plat: Vector2 = plat_pos
				var half_w: float = 80.0  # assumed platform half-width
				if abs(fighter.position.x - plat.x) < half_w and abs(fighter.position.y - plat.y) < 20.0:
					fighter.position.x += 80.0
					break
