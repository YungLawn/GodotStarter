extends Node2D

@onready var armature = %armature
@onready var label = $Label

var counter: float
var walk_speed: float = 10.0
var step_size_multiplier: float = 1.0
var direction: Vector2
var step_target: Vector2

func _ready():
	step_target = armature.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = str(abs((get_global_mouse_position() - armature.global_position).normalized().x))
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	armature.flipped = true
	armature.target = step_target - armature.position
	
	var step_size = (armature.segment_length * 0.5) * step_size_multiplier
	
	armature.rotation_multiplier = abs((get_global_mouse_position() - armature.global_position).normalized().x)
	
	if direction != Vector2.ZERO:
		counter += delta
		step_target.x = ((sin(counter * walk_speed) * step_size) * armature.flipper * armature.rotation_multiplier) + armature.position.x
		step_target.y = (cos(counter * walk_speed) * step_size) + armature.position.y + armature.segment_length * 1.5
	else:
		step_target = lerp(step_target, Vector2(armature.position.x, armature.position.y + armature.segment_length * 1.5), 0.05)

	

