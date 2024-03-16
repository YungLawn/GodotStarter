extends ItemDataWeapon
class_name  ItemDataMeleeWeapon

const SWING_OFFSET = 0.5

@export var speed: float
@export var handle_offset: float

var target

var swing_time: float
var current_swing_time: float = 0.5
var can_damage: bool

func use(target) -> void:
	if can_attack:
		self.target = target
		swing(target)
		
func bezier(t, p0, p1, p2):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

func do_damage(target):
	target.take_damage(damage, Vector2(0,0))

func swing(target):
	print(self.target)
	is_attacking = true
	
	is_attacking = true
	can_attack = false
	can_damage = true
	
	tween_swing_test(target, target.held_item)
	tween_swing_test(target, target.hold_point)
	
	#tween_swing(target, target.held_item, target.back_swing.position, target.back_step.position, target.peak_swing.position,
		#target.forward_step.position, target.forward_swing.position)
	#tween_swing(target, target.hold_point, target.back_swing.position, target.back_step.position, target.peak_swing.position,
		#target.forward_step.position, target.forward_swing.position)

func move_item(value: float):
	current_swing_time = value
	target.held_item.position = bezier(current_swing_time, target.swing_start.position, 
		target.swing_peak.position, target.swing_end.position)
	target.hold_point.position = bezier(current_swing_time, target.hand_swing_start.position, 
		target.hand_swing_peak.position, target.hand_swing_end.position)

func tween_swing_test(target, item):
		swing_time = abs(speed - 150) * 0.0075
		var tween = target.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART)
		tween.tween_method(move_item, current_swing_time, 0, 
			swing_time).set_ease(Tween.EASE_OUT).finished.connect(func(): 
				await target.get_tree().create_timer(0.1).timeout
				target.line_trail.visible = true)
		tween.tween_property(item, "rotation_degrees",
			item.rotation_degrees - 60 * target.item_rotation_flipper, swing_time).set_ease(Tween.EASE_OUT)
		tween.tween_property(item, "rotation_degrees", item.rotation_degrees + 120 * target.item_rotation_flipper, 
			swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT)
		tween.tween_method(move_item, current_swing_time - 0.5, 1,
			swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT).finished.connect(func(): 
				can_damage = false
				target.line_trail.visible = false)
		tween.tween_method(move_item, current_swing_time + 0.5, 0.5, swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(item, "rotation_degrees", item.rotation_degrees ,
			swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN_OUT).finished.connect(func():
				can_attack = true
				is_attacking = false)
