class_name MarALardo
extends Stage

## Mar-a-Lardo's Dinner Theatre — tacky gold-plated ballroom.
## Hazard: classified document folders slide onto the floor every 15s.
## Stepping on one causes a 1s stun (apply_temp_speed 0.0 for 1s).
## Document disappears on contact and auto-removes after 10s.


func _ready() -> void:
	stage_name = "Mar-a-Lardo's Dinner Theatre"
	var hazard := ClassifiedDocumentHazard.new()
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------

## An Area2D representing a classified document folder on the floor.
class DocumentFolder extends Area2D:

	const STUN_DURATION: float = 1.0
	const AUTO_REMOVE_TIME: float = 10.0
	var _auto_timer: float = 0.0
	var _triggered: bool = false

	func _ready() -> void:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(60.0, 20.0)
		shape.shape = rect
		add_child(shape)
		body_entered.connect(_on_body_entered)

	func _physics_process(delta: float) -> void:
		_auto_timer += delta
		if _auto_timer >= AUTO_REMOVE_TIME:
			queue_free()

	func _on_body_entered(body: Node2D) -> void:
		if _triggered:
			return
		if body is Fighter:
			_triggered = true
			body.apply_temp_speed(0.0, STUN_DURATION)
			queue_free()


# ---------------------------------------------------------------------------
class ClassifiedDocumentHazard extends StageHazard:

	const FLOOR_Y: float = 580.0
	const STAGE_LEFT: float = 100.0
	const STAGE_RIGHT: float = 1180.0

	func _ready() -> void:
		hazard_name = "Classified Document"
		interval = 15.0

	func activate() -> void:
		var doc := DocumentFolder.new()
		var x: float = randf_range(STAGE_LEFT, STAGE_RIGHT)
		doc.position = Vector2(x, FLOOR_Y)
		get_tree().current_scene.add_child(doc)
