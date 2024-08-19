extends Node2D

#@onready var arm = %arm
#@onready var segment_1 = %segment_1
#@onready var segment_2 = %segment_2
#@onready var anchor = %anchor
#@onready var joint_1 = %joint_1
#@onready var joint_2 = %joint_2

@onready var armature = %armature
@onready var segment_1 = %segment_1
@onready var segment_2 = %segment_2
@onready var anchor = %anchor
@onready var joint_1 = %joint_1
@onready var joint_2 = %joint_2


@export var segment_width: float = 5
@export var color: Color = '#ffffff'
@export var segment_length: float = 20

var target: Vector2
var distance: float
var height: float
var flipped: bool = false
var flipper: int
var rotation_multiplier: float = 1.0

func _ready():
	apply_values(segment_length, segment_width, color)
	
func apply_values(segment_length: float, segment_width: float, color: Color):
	segment_1.width = segment_width
	segment_2.width = segment_width
	
	segment_1.modulate = color
	segment_2.modulate = color
	
	self.segment_length = segment_length
	
func _process(delta):
	#target = get_local_mouse_position()
	flipper = -1 if flipped else 1
	
	distance = clamp(anchor.position.distance_to(target),segment_length * 0.5, segment_length * 2)
	height = lerp(height,((sqrt(pow(segment_length,2) - pow(distance/2,2))) * rotation_multiplier * flipper), delta * 30)
	
	joint_2.position.x = distance
	joint_1.position = Vector2(distance/2,height)
	
	segment_1.points[0] = anchor.position
	segment_1.points[1] = joint_1.position
	segment_2.points[0] = joint_1.position
	segment_2.points[1] = joint_2.position
	
	armature.rotation_degrees = rad_to_deg(armature.position.angle_to_point(target))
