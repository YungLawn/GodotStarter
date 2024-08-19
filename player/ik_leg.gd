extends Node2D

@onready var armature = %armature
@onready var label = $Label
@onready var target = $target

var counter: float
var walk_speed: float
var step_size_multiplier: float = 1.0
var step_offset: float
var direction: Vector2
var foot_target: Vector2
var rotation_multiplier: float
var back_pedal: bool

@export var segment_width: float = 5
@export var color: Color = '#ffffff'
@export var segment_length: float = 20

func _ready():
	foot_target = armature.position
	#armature.segment_length = segment_length
	#armature.color = color
	#armature.segment_width = segment_width
	
	armature.apply_values(segment_length, segment_width, color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	target.position = foot_target
	label.text = str(abs((get_global_mouse_position() - armature.global_position).normalized().x))
	#direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	armature.flipped = true
	armature.target = foot_target - armature.position
	
	var step_size = (armature.segment_length * 0.5) * step_size_multiplier
	var back_pedal_flipper = 1 if back_pedal else -1
	
	armature.rotation_multiplier = rotation_multiplier
	
	if direction != Vector2.ZERO:
		counter += walk_speed * (0.01 if back_pedal else -0.01)
		if counter == PI * 2:
			counter = 0
		#foot_target.x = (sin(counter + step_offset) * (step_size * armature.rotation_multiplier * armature.flipper))
		#foot_target.y = (cos(counter + step_offset) * step_size) + armature.segment_length * 1.5
		var targ_x: float = step_size * ((rotation_multiplier * 1.5) * sin(counter + step_offset))
		#var targ_x: float = step_size * sin(counter + step_offset)
		var targ_y: float = step_size * cos(counter + step_offset) + armature.segment_length * 1.5
		foot_target.x = lerp(foot_target.x, targ_x, 0.25)
		foot_target.y = lerp(foot_target.y, targ_y, 0.25)
	else:
		counter = 0
		foot_target = lerp(foot_target, Vector2(armature.position.x, armature.position.y + armature.segment_length * 1.95), 0.1)

	
