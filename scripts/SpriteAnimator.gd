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
@onready var back_arm_hold = $BackArmHold
@onready var front_arm_hold = $FrontArmHold

@onready var anim = $anim

var direction = "south"
var lookDirection = "south"
var action = "idle_"
var leg_action = "idle_"

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
	
func animate(inputDirection, inputLookDirection, hands_empty) -> void:
	if((inputDirection.x == 0 and inputDirection.y == 0)):
		action = "idle_"
		leg_action = "idle_"
	else:
		leg_action = "walk_"
		if !hands_empty:
			action = "idle_"
		else:
			action = "walk_"

	determineDirection(inputDirection, inputLookDirection)
	handle_hands(hands_empty, inputLookDirection)
	
	headAnimator.play("headanimations/head_" + action + lookDirection)
	bodyAnimator.play("bodyanimations/body_" + action + lookDirection)
	legsAnimator.play("legsanimations/legs_" + leg_action + (lookDirection if leg_action == "idle_" else direction))
			
	print(backarmSprite.rotation_degrees)
	
func handle_hands(is_empty: bool, look_direction: float):
	if is_empty:
		backarmSprite.visible = true
		frontarmSprite.visible = true
		back_arm_hold.visible = false
		front_arm_hold.visible = false
		
		back_arm_hold.z_index = 0
		front_arm_hold.z_index = 0
		
		backarmAnimator.play("backarmanimations/backarm_" + action + lookDirection)
		frontarmAnimator.play("frontarmanimations/frontarm_" + action + lookDirection)
	else:
		headAnimator.seek(0)
		bodyAnimator.seek(0)
		
		backarmSprite.visible = false
		frontarmSprite.visible = false
		back_arm_hold.visible = true
		front_arm_hold.visible = true
		
		back_arm_hold.position.x = 5
		front_arm_hold.position.x = -5
		
		match lookDirection:
			"north": 
				back_arm_hold.z_index = 0
				front_arm_hold.z_index = 0
			"south": 
				back_arm_hold.z_index = 1
				front_arm_hold.z_index = 1
			"east": 
				back_arm_hold.z_index = 0
				back_arm_hold.position.x = 0
				front_arm_hold.z_index = 1
				front_arm_hold.position.x = 0
			"southeast": 
				if headSprite.flip_h: 
					back_arm_hold.z_index = 1
					front_arm_hold.z_index = 0
				else:
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1
				back_arm_hold.position.x = 3.5
				front_arm_hold.position.x = -3.5

			"northeast": 
				if headSprite.flip_h: 
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1
				else:
					back_arm_hold.z_index = 1
					front_arm_hold.z_index = 0		
		
				back_arm_hold.position.x = 3.5
				front_arm_hold.position.x = -3.5

		back_arm_hold.rotation_degrees = look_direction - 90
		front_arm_hold.rotation_degrees = look_direction - 90
		
		anim.text = str(back_arm_hold.z_index , front_arm_hold.z_index)
	
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
	

