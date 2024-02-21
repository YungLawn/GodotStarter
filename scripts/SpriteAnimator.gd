extends Node2D

const TURN_LIMIT: float = 0.33

@onready var player = $".."
@onready var headSprite = $Head
@onready var backarmSprite = $BackArm
@onready var frontarmSprite = $FrontArm
@onready var bodySprite = $Body
@onready var legsSprite = $Legs
@onready var back_arm_hold = $BackArmHold
@onready var front_arm_hold = $FrontArmHold
@onready var held_item = $held_item

@onready var anim = $anim

var idle_index: int = 30
const TOTAL_FRAMES: int = 6
var timer: float
var framerate: float = 1.0 / TOTAL_FRAMES
var x_frame: int
var y_frame_bottom: int
var y_frame_top: int

var test : Vector2 = Vector2(0,-3)
var arm_pos_east = [Vector2(0,-5), Vector2(0,-5)]
var arm_pos_northeast = [Vector2(1,-6), Vector2(-2,-5)]
var arm_pos_southeast = [Vector2(-1,-4.5), Vector2(0,-6)]
var arm_pos_north = [Vector2(-2,-5), Vector2(2,-5)]
var arm_pos_south = [Vector2(-2.5,-4), Vector2(2.5,-4)]

func _ready():
	backarmSprite.frame = idle_index
	frontarmSprite.frame = idle_index
	legsSprite.frame = idle_index
	
func _process(delta):
	timer += delta
	if timer > framerate:
		timer -= framerate
		x_frame = (x_frame + 1) % TOTAL_FRAMES
	
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
	determineDirection(inputDirection, inputLookDirection.normalized())
	
	if((inputDirection.x == 0 and inputDirection.y == 0)):
		backarmSprite.frame = idle_index
		frontarmSprite.frame = idle_index
		legsSprite.frame = idle_index
	else:
		var coords_bottom: Vector2 = Vector2(x_frame, y_frame_bottom)
		var coords_top: Vector2 = Vector2(x_frame, y_frame_top)
		backarmSprite.frame_coords = coords_top
		frontarmSprite.frame_coords = coords_top
		legsSprite.frame_coords = coords_bottom
		
	#$"../Label".text = str(1.0/6.0)
		
func handle_hands(held_item_offset: Vector2, hand_sempty: bool):
	if hand_sempty:
		backarmSprite.visible = true
		frontarmSprite.visible = true
		back_arm_hold.visible = false
		front_arm_hold.visible = false
		
		back_arm_hold.z_index = 0
		front_arm_hold.z_index = 0
		
	else:
		backarmSprite.visible = false
		frontarmSprite.visible = false
		back_arm_hold.visible = true
		front_arm_hold.visible = true
		
		match y_frame_top:
			0: 
				#print("north")
				#held_item.position = held_item.position * 0.95
				front_arm_hold.position = arm_pos_north[0]
				back_arm_hold.position = arm_pos_north[1]
				
				back_arm_hold.z_index = 0
				front_arm_hold.z_index = 0
				
				front_arm_hold.flip_h = true
				back_arm_hold.flip_h = true

			4: 
				#print("south")
				front_arm_hold.position = arm_pos_south[0]
				back_arm_hold.position = arm_pos_south[1]
				bodySprite.z_index = 0
				
				if legsSprite.flip_h:
					front_arm_hold.z_index = 0
					back_arm_hold.z_index = 1
				else:
					front_arm_hold.z_index = 1
					back_arm_hold.z_index = 0
					
				front_arm_hold.flip_h = false
				back_arm_hold.flip_h = false

			2: 
				back_arm_hold.z_index = 0
				front_arm_hold.z_index = 1
				front_arm_hold.position = arm_pos_east[0]
				back_arm_hold.position = arm_pos_east[1]
				#print("east")
				if headSprite.flip_h:
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = false
				else:
					back_arm_hold.flip_h = true

			3: 
				#print("southeast")
				front_arm_hold.position = arm_pos_southeast[0]
				back_arm_hold.position = arm_pos_southeast[1]
				
				if headSprite.flip_h: 
					front_arm_hold.position = Vector2(-arm_pos_southeast[0].x, arm_pos_southeast[0].y)
					back_arm_hold.position = Vector2(-arm_pos_southeast[1].x, arm_pos_southeast[1].y)
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = false
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1
				else:
					back_arm_hold.flip_h = true
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1

			1: 
				#print("northeast")
				front_arm_hold.position = arm_pos_northeast[0]
				back_arm_hold.position = arm_pos_northeast[1]
				
				if headSprite.flip_h:
					front_arm_hold.position = Vector2(arm_pos_southeast[0].x - 0.5, arm_pos_southeast[0].y - 1.5)
					back_arm_hold.position = Vector2(-arm_pos_southeast[1].x + 1, arm_pos_southeast[1].y + 1)
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = false
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1
				else:
					front_arm_hold.flip_h = false
					back_arm_hold.flip_h = true
					back_arm_hold.z_index = 0
					front_arm_hold.z_index = 1


		var rad_to_item = rad_to_deg(position.angle_to_point(held_item.position + (held_item_offset)))

		back_arm_hold.rotation_degrees = rad_to_item - 90
		front_arm_hold.rotation_degrees = rad_to_item - 90

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
			#lookDirection = "southeast"
			y_frame_top = 3
			idle_index = 33
			bodySprite.texture.region = Rect2(48,16,16,16)
			headSprite.texture.region = Rect2(48,0,16,16)
		else: 
			#lookDirection = "south"
			y_frame_top = 4
			idle_index = 34
			bodySprite.texture.region = Rect2(0,16,16,16)
			headSprite.texture.region = Rect2(64,0,16,16)
		
	if(inputLookDirection.y < -TURN_LIMIT):
		unflipLookSprites()
		if abs(inputLookDirection.x) > TURN_LIMIT:
			if inputLookDirection.x < 0:
				flipLookSprites()
			#lookDirection = "northeast"
			y_frame_top = 1
			idle_index = 31
			bodySprite.texture.region = Rect2(16,16,16,16)
			headSprite.texture.region = Rect2(16,0,16,16)
		else: 
			#lookDirection = "north"
			y_frame_top = 0
			idle_index = 30
			bodySprite.texture.region = Rect2(0,16,16,16)
			headSprite.texture.region = Rect2(0,0,16,16)
		
	if(abs(inputLookDirection.y) < TURN_LIMIT):
		#lookDirection = "east"
		y_frame_top = 2
		idle_index = 32
		bodySprite.texture.region = Rect2(32,16,16,16)
		headSprite.texture.region = Rect2(32,0,16,16)
		
		
	
	if(inputDirection.y < 0):
		unflipLegs()
		if(abs(inputDirection.x) > 0):
			#direction = "northeast"
			y_frame_bottom = 1
			if(inputDirection.x < 0):
				flipLegs()
			return
		else: 
			#direction = "north"
			y_frame_bottom = 0
			
	if(inputDirection.y > 0):
		unflipLegs()
		if(abs(inputDirection.x) > 0):
			#direction = "southeast"
			y_frame_bottom = 3
			if(inputDirection.x < 0):
				flipLegs()
			return
		else: 
			#direction = "south"
			y_frame_bottom = 4
		
	if(abs(inputDirection.x) > 0):
		unflipLegs()
		#direction = "east"
		y_frame_bottom = 2
		if(inputDirection.x < 0):
			flipLegs()

