extends Node2D

@onready var p0 = $p0.position
@onready var p1 = $p1.position
@onready var p2 = $p2.position
@onready var sprite = $Sprite2D
@onready var label = $Label

var can_swing: bool = true
var current_time: float = 0.5
var swing_time: float = 0.5

func _ready():
	sprite.position = bezier(0.5, p0, p1, p2)

func _unhandled_input(event):
	if Input.is_action_pressed("left click"):
		if can_swing:
			can_swing = false
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART)
			tween.tween_method(swing, current_time, 0, swing_time).set_ease(Tween.EASE_OUT)
			tween.tween_property(sprite, "rotation_degrees",
				sprite.rotation_degrees - 60, swing_time).set_ease(Tween.EASE_OUT)
			tween.tween_property(sprite, "rotation_degrees",
				sprite.rotation_degrees + 120, swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT)
			tween.tween_method(swing, current_time - 0.5, 1, swing_time).set_delay(swing_time).set_ease(Tween.EASE_OUT)
			tween.tween_method(swing, current_time + 0.5, 0.5, swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN)
			tween.tween_property(sprite, "rotation_degrees", sprite.rotation_degrees,
				swing_time).set_delay(swing_time * 2).set_ease(Tween.EASE_IN).finished.connect(func():can_swing=true)

func _process(delta):
	label.text = str(current_time)
	
func bezier(t, p0, p1, p2):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
	
func swing(value: float):
	current_time = value
	sprite.position = bezier(current_time, p0, p1, p2)
