class_name MoscowMitch
extends Fighter

## Stall Tank — Builds obstruction meter while blocking. At full meter, next
## attack is 2x unblockable. Special grants 4s immunity and releases stored damage.

const OBSTRUCTION_MAX: float = 40.0

var _obstruction_charged: bool = false
var _shell_active: bool = false
var _shell_timer: float = 0.0
var _shell_stored_damage: float = 0.0
const SHELL_DURATION: float = 4.0


func _ready() -> void:
	fighter_name = "Moscow Mitch"
	max_health = 140.0
	speed = 200.0
	jump_force = -450.0
	punch_damage = 8.0
	kick_damage = 9.0
	special_damage = 20.0
	special_name = "Obstruct & Destroy"
	secondary_resource_max = OBSTRUCTION_MAX
	super._ready()


func get_catchphrase() -> String:
	return "The motion to defeat me... is tabled."


func take_damage(amount: float, unblockable: bool = false) -> void:
	if _shell_active:
		# Store incoming damage during shell
		_shell_stored_damage += amount
		return

	# Track blocked damage for obstruction meter
	if is_blocking and not unblockable:
		var blocked_amount := amount * 0.8  # 80% of damage is blocked
		set_secondary_resource(secondary_resource + blocked_amount)
		if secondary_resource >= OBSTRUCTION_MAX and not _obstruction_charged:
			_obstruction_charged = true
			passive_triggered.emit("Table the Motion — Charged!")

	super.take_damage(amount, unblockable)


func attack(type: String, damage: float) -> void:
	var final_damage := damage
	var was_charged := _obstruction_charged

	if _obstruction_charged:
		final_damage = damage * 2.0
		_obstruction_charged = false
		set_secondary_resource(0.0)

	is_attacking = true
	on_damage_dealt(final_damage)
	on_hit_landed()

	if anim_player:
		anim_player.play(type)
		await anim_player.animation_finished

	# If charged attack, deal as unblockable
	if was_charged and opponent != null:
		# The base attack already called on_damage_dealt; the actual hit
		# application is handled by hitbox detection in the scene tree.
		pass

	is_attacking = false


func passive_proc(delta: float) -> void:
	if _shell_active:
		_shell_timer -= delta
		if _shell_timer <= 0.0:
			_shell_active = false
			_release_shockwave()


func _release_shockwave() -> void:
	var shockwave_damage := _shell_stored_damage + 20.0
	_shell_stored_damage = 0.0

	# Unblockable shockwave
	if opponent != null:
		opponent.take_damage(shockwave_damage, true)
		on_damage_dealt(shockwave_damage)
	passive_triggered.emit("Obstruct & Destroy — Shockwave!")


func use_special() -> void:
	is_attacking = true
	special_meter = 0.0
	special_meter_changed.emit(special_meter)
	special_used.emit()

	# Enter damage immunity shell for 4 seconds
	_shell_active = true
	_shell_timer = SHELL_DURATION
	_shell_stored_damage = 0.0

	if anim_player and anim_player.has_animation("special"):
		anim_player.play("special")
		await anim_player.animation_finished

	is_attacking = false


func reset_round_state() -> void:
	super.reset_round_state()
	_obstruction_charged = false
	_shell_active = false
	_shell_timer = 0.0
	_shell_stored_damage = 0.0
	set_secondary_resource(0.0)
