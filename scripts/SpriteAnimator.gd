extends Node2D

@onready var headAnimator= $Head/HeadAnimationPlayer
@onready var backarmAnimator = $BackArm/BackArmAnimationPlayer
@onready var frontarmAnimator = $FrontArm/FrontArmAnimationPlayer
@onready var bodyAnimator = $Body/BodyAnimationPlayer
@onready var legsAnimator = $Legs/LegsAnimationPlayer
@onready var headSprite = $Head
@onready var backarmSprite = $BackArm
@onready var frontarmSprite = $FrontArm
@onready var bodySprite = $Body
@onready var legsSprite = $Legs

var direction = "south"
var lookDirection = "south"
var action = "idle_"
@export var reverse = false

const idleInterval = 3;
var framerate:float = 1;
@export var framerateMult:float = 1
var timer = 0;
var reverseTimer = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	moveTime(delta)
	
func moveTime(delta):
	timer = reverseTimer if reverse else timer
	
	timer += delta * framerateMult
	if(timer >= framerate): 
		timer -= framerate
	
	reverseTimer -= delta * framerateMult
	if(reverseTimer <= 0): 
		reverseTimer += framerate

		
func backpedal(inputDirection, inputLookDirection):
	var relation = abs(int(rad_to_deg(inputDirection.angle()))) + abs(int(inputLookDirection))
	if(relation in range(112.5, 250) and action != "idle_"):
		reverse = true
		
		if(lookDirection == "northeast"):
			if(direction == "southeast"):
				direction = "northeast"
		elif(lookDirection == "southeast"):
			if(direction == "northeast"):
				direction = "southeast"
			
		if(legsSprite.flip_h):
			unflipLegs()
		else: flipLegs()
	else:
		reverse = false
	$"../Debug".text = "Top Angle: " + str(int(inputLookDirection))
	$"../Debug2".text = "relation: " + str(relation)
	$"../Debug3".text = "Legs: " + str(direction) 
	
func flipLegs():
	legsSprite.flip_h = true
	
func unflipLegs():
	legsSprite.flip_h = false
	
func flipLookSprites():
	headSprite.flip_h = true
	backarmSprite.flip_h = true
	frontarmSprite.flip_h = true
	bodySprite.flip_h = true
	
func unflipLookSprites():
	headSprite.flip_h = false
	backarmSprite.flip_h = false
	frontarmSprite.flip_h = false
	bodySprite.flip_h = false
	
func animate(inputDirection, inputLookDirection) -> void:
	$"../Debug3".text = action
	if(inputDirection.x == 0 and inputDirection.y == 0):
		action = "idle_"
		timer = 0
		reverseTimer = 0
	else:
		action = "walk_"
		
	determineDirection(inputDirection, inputLookDirection)
	#backpedal(inputDirection, inputLookDirection)
	headAnimator.play("headanimations/head_" + action + lookDirection)
	#headAnimator.seek(reverseTimer if reverse else timer)
	bodyAnimator.play("bodyanimations/body_" + action + lookDirection)
	#bodyAnimator.seek(reverseTimer if reverse else timer)
	backarmAnimator.play("backarmanimations/backarm_" + action + lookDirection)
	#backarmAnimator.seek(reverseTimer if reverse else timer)
	frontarmAnimator.play("frontarmanimations/frontarm_" + action + lookDirection)
	#frontarmAnimator.seek(reverseTimer if reverse else timer)
	legsAnimator.play("legsanimations/legs_" + action + (lookDirection if action == "idle_" else direction))
	#legsAnimator.seek(reverseTimer if reverse else timer)
		
func determineDirection(inputDirection, inputLookDirection):
	if(abs(inputLookDirection) > 90):
		flipLegs()
	else: 
		unflipLegs()
	
	if(abs(inputLookDirection) < 22.5):
		unflipLookSprites()
		lookDirection = "east"
	elif(abs(inputLookDirection) > 157.5):
		flipLookSprites()
		lookDirection = "east"
	elif(abs(inputLookDirection) > 67.5 and abs(inputLookDirection) < 112.5 and inputLookDirection < 1):
		unflipLookSprites()
		lookDirection = "north"
	elif(abs(inputLookDirection) > 67.5 and abs(inputLookDirection) < 112.5 and inputLookDirection > 1):
		unflipLookSprites()
		lookDirection = "south"
	elif(inputLookDirection < -22.5 and inputLookDirection > -67.5):
		unflipLookSprites()
		lookDirection = "northeast"
	elif(inputLookDirection > 22.5 and inputLookDirection < 67.5):
		unflipLookSprites()
		lookDirection = "southeast"
	elif(inputLookDirection > 112.5 and inputLookDirection < 157.5):
		flipLookSprites()
		lookDirection = "southeast"
	elif(inputLookDirection < -112.5 and inputLookDirection > -157.5):
		flipLookSprites()
		lookDirection = "northeast"

	
	if(inputDirection.y < 0):
		unflipLegs()
		if(abs(inputDirection.x) > 0):
			direction = "northeast"
			if(inputDirection.x < 0):
				flipLegs()
			return
		else: direction = "north"
		
	if(inputDirection.y > 0):
		unflipLegs()
		if(abs(inputDirection.x) > 0):
			direction = "southeast"
			if(inputDirection.x < 0):
				flipLegs()
			return
		else: direction = "south"
		
	if(abs(inputDirection.x) > 0):
		unflipLegs()
		direction = "east"
		if(inputDirection.x < 0):
			flipLegs()
	

