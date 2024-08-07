extends Node2D

@onready var arm = %arm
@onready var r_bicep = %r_bicep
@onready var r_forearm = %r_forearm
@onready var r_shoulder = %r_shoulder
@onready var r_elbow = %r_elbow
@onready var r_hand = %r_hand

@export var arm_width: float = 5
@export var color: Color = '#ffffff'
@export var segment_length: float = 20

var target: Vector2
var distance: float
var height: float
var flipped: bool

func _ready():
	r_bicep.width = arm_width
	r_forearm.width = arm_width
	
	r_bicep.modulate = color
	r_forearm.modulate = color

func _process(delta):
	#target = get_local_mouse_position()
	var flipper = -1 if target.x < 0 else 1
	
	distance = clamp(r_shoulder.position.distance_to(target),segment_length, segment_length * 2)
	height = lerp(height,(sqrt(pow(segment_length,2) - pow(distance/2,2))) * flipper, delta * 30)
	
	r_hand.position.x = distance
	r_elbow.position = Vector2(distance/2,height)
	
	r_bicep.points[0] = r_shoulder.position
	r_bicep.points[1] = r_elbow.position
	r_forearm.points[0] = r_elbow.position
	r_forearm.points[1] = r_hand.position
	
	arm.rotation_degrees = rad_to_deg(arm.position.angle_to_point(target))

