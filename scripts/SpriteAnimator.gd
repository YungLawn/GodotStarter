extends Node2D

const TURN_LIMIT: float = 0.33

@onready var player = $".."
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
@onready var held_item = $held_item

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
	
func animate(inputDirection, inputLookDirection, hands_empty, held_item_offset) -> void:
	if((inputDirection.x == 0 and inputDirection.y == 0)):
		action = "idle_"
		leg_action = "idle_"
	else:
		leg_action = "walk_"
		action = "walk_"

	determineDirection(inputDirection, inputLookDirection.normalized())
	handle_hands(hands_empty, held_item_offset)
	
	headAnimator.play("headanimations/head_" + action + lookDirection)
	bodyAnimator.play("bodyanimations/body_" + action + lookDirection)
	legsAnimator.play("legsanimations/legs_" + leg_action + (lookDirection if leg_action == "idle_" else direction))
			
	#print(backarmSprite.rotation_degrees)
	
func handle_hands(is_empty: bool, held_item_offset: Vector2):
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
		
		back_arm_hold.position.x = 4
		front_arm_hold.position.x = -4
		
		match lookDirection:
			"north": 
				back_arm_hold.z_index = 0
				front_arm_hold.z_index = 0
				
				front_arm_hold.flip_h = true
				back_arm_hold.flip_h = true
				
			"south": 
				if headSprite.flip_h:
					front_arm_hold.z_index = 0
					back_arm_hold.z_index = 1
				else:
					back_arm_hold.z_index = 1
					front_arm_hold.z_index = 1
				
				front_arm_hold.flip_h = false
				back_arm_hold.flip_h = false
				
			"east": 
				if headSprite.flip_h:
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = false
				else:
					back_arm_hold.flip_h = true
				back_arm_hold.z_index = 0
				back_arm_hold.position.x = 0
				front_arm_hold.z_index = 1
				front_arm_hold.position.x = 0
				
			"southeast": 
				if headSprite.flip_h: 
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = true
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1
					back_arm_hold.position.x = 0
					front_arm_hold.position.x = 2.5
				else:
					back_arm_hold.flip_h = false
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1
					back_arm_hold.position.x = 0
					front_arm_hold.position.x = -2.5

			"northeast": 
				if headSprite.flip_h:
					front_arm_hold.flip_h = true
				else:
					back_arm_hold.flip_h = true
					front_arm_hold.flip_h = false
				if headSprite.flip_h: 
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1
				else:
					back_arm_hold.z_index = 1
					front_arm_hold.z_index = 0		
		
				back_arm_hold.position.x = 3
				front_arm_hold.position.x = -3

		#front_arm_hold.flip_h = false
		#back_arm_hold.flip_h = false
		var rad_to_item = rad_to_deg(position.angle_to_point(held_item.position + held_item_offset))
		
		back_arm_hold.rotation_degrees = rad_to_item- 90
		front_arm_hold.rotation_degrees = rad_to_item - 90
		
		anim.text = str(position.angle_to_point(held_item.position))
	
func determineDirection(inputDirection, inputLookDirection):
	if inputLookDirection.x < 0:
		flipLegs()
	else:
		unflipLegs()
		
	if(inputLookDirection.y > TURN_LIMIT):
		unflipLookSprites()
		if abs(inputLookDirection.x) > TURN_LIMIT:
			if inputLookDirection.x < 0:
				flipLookSprites()
			lookDirection = "southeast"
		else: lookDirection = "south"
		
	if(inputLookDirection.y < -TURN_LIMIT):
		unflipLookSprites()
		if abs(inputLookDirection.x) > TURN_LIMIT:
			if inputLookDirection.x < 0:
				flipLookSprites()
			lookDirection = "northeast"
		else: lookDirection = "north"
		
	if(abs(inputLookDirection.y) < TURN_LIMIT):
		lookDirection = "east"
	
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
	

