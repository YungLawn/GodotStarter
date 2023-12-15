extends CharacterBody2D

@export var SPEED = 0
@export var SPRINTMULTIPLIER = 1.5
var isSprinting = false
@onready var direction = Vector2(0,0)
@onready var lookDirection = Vector2(0,0)

func _ready():
	pass

func _physics_process(delta):
	velocity = direction.normalized() * (SPEED * SPRINTMULTIPLIER if isSprinting else SPEED)
	move_and_slide()
	
func _process(delta):
	toggleSprint()
	
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	lookDirection = rad_to_deg(get_angle_to(get_global_mouse_position()))
	
	$Debug.text = str(position)

	$BaseSprite.animate(direction, lookDirection)
	
	
func toggleSprint():
	if Input.is_action_just_pressed("sprint") and isSprinting == false:
		isSprinting = true
	elif Input.is_action_just_pressed("sprint") and isSprinting == true:
		isSprinting = false
	if(direction.x == 0 and direction.y == 0):
		isSprinting = false
	return isSprinting
