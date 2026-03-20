class_name BookBanBonfire
extends Stage

## Book Ban Bonfire — burning library where banned books fight back.
## Hazard: a banned book projectile (3 dmg) flies across the stage every 10s.
## Getting hit grants a +10% damage buff for 8s (tracked via meta on the fighter).


func _ready() -> void:
	stage_name = "Book Ban Bonfire"
	var hazard := FlyingBookHazard.new()
	register_hazard(hazard)
	super._ready()


# ---------------------------------------------------------------------------
class FlyingBook extends Projectile:

	## Override on_hit to apply the knowledge buff to the struck fighter.
	func on_hit(target: Fighter) -> void:
		_apply_knowledge_buff(target)

	func _apply_knowledge_buff(fighter: Fighter) -> void:
		const BUFF_DURATION: float = 8.0
		const BUFF_AMOUNT: float = 0.10

		# Accumulate the buff multiplier stored in meta
		var current: float = fighter.get_meta("knowledge_buff", 0.0)
		fighter.set_meta("knowledge_buff", current + BUFF_AMOUNT)

		# Start a timer to remove this specific buff stack
		var t := Timer.new()
		t.wait_time = BUFF_DURATION
		t.one_shot = true
		fighter.add_child(t)
		t.timeout.connect(func() -> void:
			if is_instance_valid(fighter):
				var val: float = fighter.get_meta("knowledge_buff", 0.0)
				fighter.set_meta("knowledge_buff", maxf(val - BUFF_AMOUNT, 0.0))
			t.queue_free()
		)
		t.start()


# ---------------------------------------------------------------------------
class FlyingBookHazard extends StageHazard:

	const BOOK_DAMAGE: float = 3.0
	const STAGE_LEFT: float = 0.0
	const STAGE_RIGHT: float = 1280.0
	const FLOOR_Y: float = 500.0

	func _ready() -> void:
		hazard_name = "Flying Book"
		interval = 10.0

	func activate() -> void:
		var from_left: bool = randi() % 2 == 0
		var book := FlyingBook.new()
		book.damage = BOOK_DAMAGE
		book.unblockable = false
		book.speed = 400.0
		book.lifetime = 4.0
		book.direction = 1.0 if from_left else -1.0
		book.position = Vector2(STAGE_LEFT if from_left else STAGE_RIGHT, FLOOR_Y)
		# No owner — hazard projectile hits both fighters
		book.owner_fighter = null
		get_tree().current_scene.add_child(book)
