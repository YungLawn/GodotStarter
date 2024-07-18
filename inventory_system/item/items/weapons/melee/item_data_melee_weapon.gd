extends ItemDataWeapon
class_name  ItemDataMeleeWeapon

const SWING_OFFSET = 0.6

@export var speed: float
@export var handle_offset: float

var target

var swing_time: float
var current_swing_time: float
var current_hand_swing_time: float
var can_damage: bool = false

func use(target) -> void:
	print("BOOBOO")
	#if can_attack:
		#self.target = target
		#swing(target)
		
func bezier(t, p0, p1, p2):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r

func do_damage(target):
	target.take_damage(damage, Vector2(0,0))

func swing(target):
	#print(self.target)
	is_attacking = true
	
	is_attacking = true
	can_attack = false
	
	#animate_swing(target, target.held_item)

#func move_item(value: float):
	#current_swing_time = value
	#target.held_item.position = bezier(current_swing_time, target.swing_start.position, 
		#target.swing_peak.position, target.swing_end.position)
#
#func move_hand(value: float):
	#current_hand_swing_time = value
	#target.hold_point.position = bezier(current_hand_swing_time, target.hand_swing_start.position, 
		#target.hand_swing_peak.position, target.hand_swing_end.position)
#
#func animate_swing(target, item):
		#swing_time = abs(speed - 150) * 0.005
		##var starting_hand_offset: float = 0.5 + hold_point_offset * 2
		#var swing_offset: float = 1 - 0.5
		##var hand_swing_offset: float = 1 - 0.5 - hold_point_offset
		#var hand = target.hold_points
		#current_swing_time = 0.5
		##current_hand_swing_time = 0.5 + hold_point_offset * 2.125
#
		#var tween = target.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT)
		#
		#tween.tween_method(move_item, current_swing_time, 0, 
			#swing_time).set_ease(Tween.EASE_IN_OUT).finished.connect(func(): 
				##await target.get_tree().create_timer(0.1).timeout
				#target.line_trail.visible = true
				#can_damage = true)
		#tween.tween_property(item, "rotation_degrees",
			#item.rotation_degrees - 30 * target.item_rotation_flipper, swing_time).set_ease(Tween.EASE_IN_OUT)
			#
		#tween.tween_property(item, "rotation_degrees", item.rotation_degrees + 90 * target.item_rotation_flipper, 
			#swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT)
		#tween.tween_method(move_item, current_swing_time - swing_offset, 1,
			#swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT).finished.connect(func(): 
				#can_damage = false
				#target.line_trail.visible = false)
				#
		#tween.tween_method(move_item, current_swing_time + swing_offset, 0.5, swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN_OUT)
		#tween.tween_property(item, "rotation_degrees", item.rotation_degrees ,
			#swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN_OUT).finished.connect(func():
				#can_attack = true
				#is_attacking = false)
				#
		##tween.tween_method(move_hand, current_hand_swing_time, 0, 
			##swing_time).set_ease(Tween.EASE_IN_OUT)
			##
		##tween.tween_method(move_hand, current_hand_swing_time - hand_swing_offset, 1,
			##swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT)
				##
		##tween.tween_method(move_hand, current_hand_swing_time + hand_swing_offset * 0.75, starting_hand_offset, swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN_OUT)
