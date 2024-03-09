extends Node2D

@onready var p0 = $p0.position
@onready var p1 = $p1.position
@onready var p2 = $p2.position
@onready var sprite = $Sprite2D

var can_swing: bool = false
var swing_forward: bool = true
var swing_backward: bool = false
var time: float = 0

func _unhandled_input(event):
	if Input.is_action_pressed("left click"):
		can_swing = true
		if can_swing:
			swing(0.075, sprite)



func _physics_process(delta):
	if can_swing:
		swing(0.075, sprite)

func bezier(t, p0, p1, p2):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
	
func swing(swing_speed, item):
	print(time)
	#time += swing_speed
	item.position = bezier(time, p0, p1, p2)
	if swing_forward:
		if time < 0.99:
			time += swing_speed 
			sprite.rotation += swing_speed * 1.75
			#print(pow(2, -10 * time))
		else:
			sprite.rotation_degrees = 90
			sprite.flip_h = true
			can_swing = false
			swing_forward = false
			swing_backward = true

	elif swing_backward:
		if time > 0.01:
			time -= swing_speed
			sprite.rotation -= swing_speed * 1.75
		else:
			sprite.rotation_degrees = -90
			sprite.flip_h = false
			can_swing = false
			swing_forward = true
			swing_backward = false



