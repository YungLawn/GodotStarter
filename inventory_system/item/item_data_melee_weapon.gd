extends ItemDataWeapon
class_name  ItemDataMeleeWeapon

@export var speed: float
@export var effective_range: int

var swing_time: float
var can_damage: bool

func use(target) -> void:
	if can_attack:
		swing(target)
		
func do_damage(target):
	target.take_damage(damage, Vector2(0,0))

func swing(target):
	target.item_swung()
	can_attack = false
	can_damage = true
	var attack_direction: Vector2 = target.lookDirection
	swing_time = abs((speed - (weight * 50)) - 150) * 0.0025
	var tween = target.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.TRANS_LINEAR)
	
	var wind_up_degrees: int = -60
	var swing_degrees: int = 90
	var follow_through_degrees: int = 120
	
	var flat_time = swing_time * 1.0 / 6
	
	var wind_up: float = flat_time * 0.5
	var back_step: float = flat_time * 0.25
	var swing: float = flat_time * 0.25
	var front_step: float = flat_time * 0.5
	var follow_through: float = flat_time
	
	var center: float = flat_time
	
	if target.lookDirection.normalized().x < 0:
		wind_up_degrees = 60
		swing_degrees = -90
		follow_through_degrees = -120

	tween.set_parallel(true)
	
	#wind up start
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees + wind_up_degrees, back_step + wind_up)
	tween.tween_property(target.held_item, "position", target.back_step.position, back_step)
	
	tween.tween_property(target.held_item, "position", target.back_swing.position, wind_up).set_delay(
		back_step)
	
	#forward
	tween.tween_property(target.held_item, "position", target.back_step.position, back_step).set_delay(
		back_step + wind_up)
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees + swing_degrees, back_step + swing).set_delay(
		back_step + wind_up)
	
	#peak
	tween.tween_property(target.held_item, "position", target.peak_swing.position, swing).set_delay(
		back_step + wind_up + back_step)
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees + follow_through_degrees, front_step + follow_through + front_step).set_delay(
		back_step + wind_up + back_step)
	
	tween.tween_property(target.held_item, "position", target.forward_step.position, front_step).set_delay(
		back_step + wind_up + back_step + swing)
	
	tween.tween_property(target.held_item, "position", target.forward_swing.position , follow_through).set_delay(
		back_step + wind_up + back_step + swing + front_step)
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees, (front_step*1.5) + (center*1.5)).set_delay(
		back_step + wind_up + back_step + swing + front_step + follow_through)
	#follow through finished
	
	tween.tween_property(target.held_item, "position", target.forward_step.position, front_step * 2).set_delay(
		back_step + wind_up + back_step + swing + front_step + follow_through)
	
	tween.tween_property(target.held_item, "position", target.held_item.position, center * 2).set_delay(
		back_step + wind_up + back_step + swing + front_step + follow_through + front_step)
	#centered

	await target.get_tree().create_timer(back_step + wind_up + back_step + swing + front_step + follow_through).timeout
	can_damage = false

	await target.get_tree().create_timer(follow_through + front_step + center).timeout
	can_attack = true

