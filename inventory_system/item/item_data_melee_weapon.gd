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
	var swing_speed = abs((speed - (weight * 100)) - 200) * 0.0025
	var tween = target.create_tween()
	
	var wind_up_degrees: int = -45
	var swing_degrees: int = 75
	var follow_through_degrees: int = 110
	
	var wind_up: float = swing_speed * 0.25
	var swing: float = swing_speed * 0.05
	var follow_through: float = swing_speed * 0.15
	var center: float = swing_speed * 0.55
	
	if target.lookDirection.normalized().x < 0:
		wind_up_degrees = 45
		swing_degrees = -75
		follow_through_degrees = -110
	
	can_swing = false
	tween.set_parallel(true)
	
	tween.tween_property(target.held_item, "position", target.back_swing.position, wind_up)
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees + wind_up_degrees, wind_up)
	
	tween.tween_property(target.held_item, "position", target.peak_swing.position, swing).set_delay(wind_up)
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees + swing_degrees, swing).set_delay(wind_up)
	
	tween.tween_property(target.held_item, "position", target.forward_swing.position , follow_through).set_delay(wind_up + swing)
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees + follow_through_degrees, follow_through).set_delay(wind_up + swing)
	
	tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees, center).set_delay(wind_up + swing + follow_through)
	tween.tween_property(target.held_item, "position", target.held_item.position, center).set_delay(wind_up + swing + follow_through)

	await target.get_tree().create_timer(swing_speed).timeout
	can_swing = true


