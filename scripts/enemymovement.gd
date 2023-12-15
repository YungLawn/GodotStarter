extends CharacterBody2D

@export var SPEED: int
@export var SPRINTMULTIPLIER: float
@export var is_chasing = false
@onready var direction = Vector2(0,0)
@onready var lookDirection = Vector2(0,0)
@onready var player = $"../player"

func _ready():
	pass

func _physics_process(delta):
	velocity = direction.normalized() * SPEED
	move_and_slide()
	
func _process(delta):
	#direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	if is_chasing:
		direction = Vector2(cos(position.angle_to_point(player.position)), sin(position.angle_to_point(player.position))).normalized()
	else: direction = Vector2(0,0)
	lookDirection = rad_to_deg(get_angle_to(player.position))

	$Debug.text = str(position)

	$BaseSprite.animate(direction, lookDirection)
	
func _on_detection_zone_body_entered(body):
	if body == player:
		is_chasing = true

func _on_detection_zone_body_exited(body):
	if body == player:
		is_chasing = false
