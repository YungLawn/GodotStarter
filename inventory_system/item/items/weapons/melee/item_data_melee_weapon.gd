extends ItemDataWeapon
class_name  ItemDataMeleeWeapon

#const SWING_OFFSET = 0.6

@export var speed: float
@export var handle_offset: float
@export var hit_point: Vector2

var target

var swing_time: float
var current_swing_time: float = 0.5
var can_damage: bool = false

func use(target) -> void:
	if can_attack and not target.inventory_open:
		#print("BOOBOO")
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
	#print(target)
	is_attacking = true

	can_attack = false
	
	animate_swing(target, target.held_item)

func move_item(value: float):
	target.label.text = str(current_swing_time)
	current_swing_time = value
	target.held_item.position = bezier(current_swing_time, target.swing_start.position, 
		target.swing_peak.position, target.swing_end.position)

func animate_swing(target, item):
		swing_time = abs(speed - 150) * 0.0025

		var tween = target.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT)
		
		tween.tween_method(move_item, 0.5, 0.0, 
			swing_time).set_ease(Tween.EASE_IN_OUT).finished.connect(func(): 
				can_damage = true
				await target.get_tree().create_timer(0.01).timeout
				target.line_trail.modulate = Color(1,1,1,1))
		
		tween.tween_property(item, "rotation_degrees",
			item.rotation_degrees - 30 * target.item_rotation_flipper, swing_time).set_ease(Tween.EASE_IN_OUT)
			
		tween.tween_property(item, "rotation_degrees", item.rotation_degrees + (30 + rotation_offset) * target.item_rotation_flipper, 
			swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT)
			
		#tween.tween_property(target, "position", target.position + (Crosshair.global_position - target.global_position).normalized() * weight * 0.75, swing_time * 2).set_delay(swing_time)
		
		tween.tween_method(move_item, 0.0, 1.0,
			swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT).finished.connect(func(): 
				can_damage = false
				target.line_trail.modulate = Color(1,1,1,0)
				)
		
		tween.tween_method(move_item, 1.0, 0.5, swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN_OUT)
		
		tween.tween_property(item, "rotation_degrees", item.rotation_degrees ,
			swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN_OUT).finished.connect(func():
				can_attack = true
				is_attacking = false)
