extends ItemData
class_name  ItemDataMeleeWeapon

@export var damage: int
@export var speed: float
@export var effective_range: int


var can_swing: bool = true

#var attack_cooldown : Timer = Timer.new()
	#
#func _init():
	#attack_cooldown.one_shot = true
	#attack_cooldown.autostart = false
	#attack_cooldown.timeout.connect(attack_cooldown_timeout)
#
#func attack_cooldown_timeout():
	#can_swing = true

func use(target) -> void:
	if can_swing:
		swing(target)

func swing(target):
	target.item_swung()
	var attack_direction: Vector2 = target.lookDirection
	var swing_time = abs((speed - (weight * 100)) - 200) * 0.0015
	var tween = target.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.TRANS_LINEAR)
	
	var delay: float = 0.0
	
	var wind_up_degrees: int = -45
	var swing_degrees: int = 75
	var follow_through_degrees: int = 110
	
	var flat_time = swing_time * 0.166
	
	var wind_up: float = flat_time
	var back_step: float = flat_time * 0.75
	var swing: float = flat_time * 0.25
	var front_step: float = flat_time * 0.75
	var follow_through: float = flat_time
	
	var center: float = swing_time * 0.166
	
	if target.lookDirection.normalized().x < 0:
		wind_up_degrees = 45
		swing_degrees = -75
		follow_through_degrees = -110
	
	can_swing = false
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
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees, front_step + center).set_delay(
		back_step + wind_up + back_step + swing + front_step + follow_through)
	#follow through finished
	
	tween.tween_property(target.held_item, "position", target.forward_step.position, front_step).set_delay(
		back_step + wind_up + back_step + swing + front_step + follow_through)
	
	tween.tween_property(target.held_item, "position", target.held_item.position, center).set_delay(
		back_step + wind_up + back_step + swing + front_step + follow_through + front_step)
	#centered

	await target.get_tree().create_timer(swing_time).timeout
	can_swing = true


