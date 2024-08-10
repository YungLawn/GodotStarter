extends Node2D

const TURN_LIMIT: float = 0.33

@onready var back_arm = $BackArm
@onready var front_arm = $FrontArm
@onready var body = $Body
@onready var head = $Head
@onready var held_item = %held_item
@onready var legs = $Legs

@onready var ik_back_arm = %ik_back_arm
@onready var ik_front_arm = %ik_front_arm

var idle_index: int = 30
const TOTAL_FRAMES: int = 6
var timer: float
var framerate: float = 1.0 / TOTAL_FRAMES
var framerate_multiplier : float = 1.0
var x_frame: int
var y_frame_bottom: int
var y_frame_top: int

var arm_pos_east = [Vector2(0,-0), Vector2(0,-0)]
var arm_pos_northeast = [Vector2(1.5,-0.5), Vector2(1.5,-0.5)]
var arm_pos_southeast = [Vector2(-1.5,-0), Vector2(-1.5,-0)]
var arm_pos_north = [Vector2(-3,-0), Vector2(3,-0)]
var arm_pos_south = [Vector2(-4,-0), Vector2(4,-0)]

func _ready():
	back_arm.frame = idle_index
	front_arm.frame = idle_index
	legs.frame = idle_index

func _process(delta):
	timer += delta
	#if timer > framerate:
		#timer -= (framerate * framerate_multiplier)
		#x_frame = (x_frame + 1) % TOTAL_FRAMES

func flipLegs():
	legs.flip_h = true
func unflipLegs():
	legs.flip_h = false
func flipLookSprites():
	head.flip_h = true
	back_arm.flip_h = true
	front_arm.flip_h = true
	body.flip_h = true
func unflipLookSprites():
	head.flip_h = false
	back_arm.flip_h = false
	front_arm.flip_h = false
	body.flip_h = false

func animate(inputDirection, inputLookDirection, SPEED) -> void:
	if timer > framerate:
		timer -= (framerate * framerate_multiplier)
		if(inputDirection == Vector2.ZERO or SPEED == 0.0):
			x_frame = 3
		else:
			x_frame = (x_frame + 1) % TOTAL_FRAMES
		
	determineDirection(inputDirection, inputLookDirection.normalized())
	if(inputDirection == Vector2.ZERO or SPEED == 0.0):
		back_arm.frame = idle_index
		front_arm.frame = idle_index
		legs.frame = idle_index
	else:
		var coords_bottom: Vector2 = Vector2(x_frame, y_frame_bottom)
		var coords_top: Vector2 = Vector2(x_frame, y_frame_top)
		back_arm.frame_coords = coords_top
		front_arm.frame_coords = coords_top
		legs.frame_coords = coords_bottom

func handle_hands(hand_sempty: bool, look_direction: Vector2, aim_point: Vector2, offset: Vector2):
	#print(aim_point.normalized())
	if hand_sempty:
		back_arm.visible = true
		front_arm.visible = true
		ik_back_arm.visible = false
		ik_front_arm.visible = false

	else:
		back_arm.visible = false
		front_arm.visible = false
		ik_back_arm.visible = true
		ik_front_arm.visible = true
		
		if aim_point.x < 0:
			ik_back_arm.flipped = true
			ik_front_arm.flipped = true
		else:
			ik_back_arm.flipped = false
			ik_front_arm.flipped = false

		match y_frame_top:
			0: 
				#print("north")
				
				ik_front_arm.flipped = true
				ik_back_arm.flipped = false
				
				ik_front_arm.position = arm_pos_north[0]
				ik_back_arm.position = arm_pos_north[1]

				move_child(ik_front_arm,body.get_index() - 1)
				move_child(held_item, body.get_index() - 2)
				move_child(ik_back_arm,body.get_index() - 1)

			4: 
				#print("south")
				
				ik_front_arm.flipped = false
				ik_back_arm.flipped = true
				
				ik_front_arm.position = arm_pos_south[0]
				ik_back_arm.position = arm_pos_south[1]

				if aim_point.x < 0:
					move_child(ik_front_arm,body.get_index() + 1)
					move_child(held_item, body.get_index() + 2)
					move_child(ik_back_arm,body.get_index() + 3)
				else:
					move_child(ik_front_arm,body.get_index() + 3)
					move_child(held_item, body.get_index() + 2)
					move_child(ik_back_arm,body.get_index() + 1)

			2: 
				#print("east")
				ik_front_arm.position = arm_pos_east[0]
				ik_back_arm.position = arm_pos_east[1]
				
				move_child(ik_front_arm,body.get_index() + 2)
				move_child(held_item, body.get_index() + 1)
				move_child(ik_back_arm,body.get_index() - 1)

			3: 
				#print("southeast")
				ik_front_arm.position = arm_pos_southeast[0]
				ik_back_arm.position = arm_pos_southeast[1]
				
				move_child(ik_front_arm,body.get_index() + 2)
				move_child(held_item, body.get_index() + 1)
				move_child(ik_back_arm,body.get_index() - 1)

				if aim_point.x < 0:
					ik_front_arm.position = Vector2(-arm_pos_southeast[0].x, arm_pos_southeast[0].y)
					ik_back_arm.position = Vector2(-arm_pos_southeast[1].x, arm_pos_southeast[1].y)

			1: 
				#print("northeast")
				move_child(ik_front_arm,body.get_index() + 2)
				move_child(held_item, body.get_index() - 2)
				move_child(ik_back_arm,body.get_index() - 1)

				if aim_point.x < 0:
					ik_front_arm.position = Vector2(-arm_pos_northeast[0].x, arm_pos_northeast[0].y)
					ik_back_arm.position = Vector2(-arm_pos_northeast[1].x, arm_pos_northeast[1].y)
				else:
					ik_front_arm.position = arm_pos_northeast[0]
					ik_back_arm.position = arm_pos_northeast[1]

		ik_back_arm.target = held_item.position - ik_back_arm.position
		ik_front_arm.target = held_item.position - ik_front_arm.position

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
			body.texture.region = Rect2(48,16,16,16)
			head.texture.region = Rect2(48,0,16,16)
		else: 
			#lookDirection = "south"
			y_frame_top = 4
			idle_index = 34
			body.texture.region = Rect2(0,16,16,16)
			head.texture.region = Rect2(64,0,16,16)
		
	if(inputLookDirection.y < -TURN_LIMIT):
		unflipLookSprites()
		if abs(inputLookDirection.x) > TURN_LIMIT:
			if inputLookDirection.x < 0:
				flipLookSprites()
			#lookDirection = "northeast"
			y_frame_top = 1
			idle_index = 31
			body.texture.region = Rect2(16,16,16,16)
			head.texture.region = Rect2(16,0,16,16)
		else: 
			#lookDirection = "north"
			y_frame_top = 0
			idle_index = 30
			body.texture.region = Rect2(0,16,16,16)
			head.texture.region = Rect2(0,0,16,16)
		
	if(abs(inputLookDirection.y) < TURN_LIMIT):
		#lookDirection = "east"
		y_frame_top = 2
		idle_index = 32
		body.texture.region = Rect2(32,16,16,16)
		head.texture.region = Rect2(32,0,16,16)
		
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

