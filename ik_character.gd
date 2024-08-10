extends CharacterBody2D

var direction: Vector2
var look_direction: Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	look_direction = get_local_mouse_position()

	move_and_slide()

