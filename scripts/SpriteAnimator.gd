extends Node2D

const TURN_LIMIT: float = 0.33

@onready var pivot_point = %pivot_point
@onready var back_arm = $BackArm
@onready var front_arm = $FrontArm
@onready var body = $Body
@onready var head = $Head
@onready var back_arm_hold = %BackArmHold
@onready var front_arm_hold = %FrontArmHold
@onready var held_item = %held_item
@onready var projectile_spawn_point = $Body/FrontArmHold/held_item/projectile_spawn_point
@onready var attack_effect_spawn_point = $Body/FrontArmHold/held_item/attack_effect_spawn_point
@onready var ranged_ray = $Body/FrontArmHold/held_item/ranged_ray
@onready var melee_hit_area = $Body/FrontArmHold/held_item/melee_hit_area
@onready var collision_shape_2d = $Body/FrontArmHold/held_item/melee_hit_area/CollisionShape2D
@onready var line_trail = $Body/FrontArmHold/held_item/melee_hit_area/line_trail
@onready var legs = $Legs

var idle_index: int = 30
const TOTAL_FRAMES: int = 6
var timer: float
var framerate: float = 1.0 / TOTAL_FRAMES
var x_frame: int
var y_frame_bottom: int
var y_frame_top: int

const BACK_ARM_MID: Rect2 = Rect2(11,2,5,11)
const BACK_ARM_FULL: Rect2 = Rect2(10,2,6,13)
const BACK_ARM_MIN: Rect2 = Rect2(12,2,4,9)

const FRONT_ARM_MID: Rect2 = Rect2(0,2,5,11)
const FRONT_ARM_FULL: Rect2 = Rect2(0,2,6,13)
const FRONT_ARM_MIN: Rect2 = Rect2(0,2,4,9)

var test : Vector2 = Vector2(0,-3)
var arm_pos_east = [Vector2(0,-0), Vector2(0,-0)]
var arm_pos_northeast = [Vector2(1.5,-0.5), Vector2(1.5,-0.5)]
var arm_pos_southeast = [Vector2(-1.5,-0), Vector2(-1.5,-0)]
var arm_pos_north = [Vector2(-3,-0), Vector2(3,-0)]
var arm_pos_south = [Vector2(-3,-0), Vector2(3,-0)]

func _ready():
	back_arm.frame = idle_index
	front_arm.frame = idle_index
	legs.frame = idle_index
	
func _process(delta):
	timer += delta
	if timer > framerate:
		timer -= framerate
		x_frame = (x_frame + 1) % TOTAL_FRAMES
	
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
	determineDirection(inputDirection, inputLookDirection.normalized())
	#print(SPEED)
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
		
	#print(y_frame_top)
		
func handle_hands(hand_sempty: bool, look_direction: Vector2, aim_point: Vector2, offset: Vector2, lerp_strength: float):
	#print(aim_point.normalized())
	if hand_sempty:
		back_arm.visible = true
		front_arm.visible = true
		back_arm_hold.visible = false
		front_arm_hold.visible = false
		
	else:
		back_arm.visible = false
		front_arm.visible = false
		back_arm_hold.visible = true
		front_arm_hold.visible = true
		
		front_arm_hold.texture.region = FRONT_ARM_MID
		back_arm_hold.texture.region = BACK_ARM_MID

		#move_child(held_item, body.get_index() + 1)
		
		match y_frame_top:
			0: 
				#print("north")
				front_arm_hold.position = arm_pos_north[0]
				back_arm_hold.position = arm_pos_north[1]
				
				move_child(front_arm_hold,body.get_index() - 1)
				move_child(held_item, body.get_index() - 2)
				move_child(back_arm_hold,body.get_index() - 1)
				
				front_arm_hold.flip_h = true
				back_arm_hold.flip_h = true

			4: 
				#print("south")
				front_arm_hold.position = arm_pos_south[0]
				back_arm_hold.position = arm_pos_south[1]

				if aim_point.x < 0:
					move_child(front_arm_hold,body.get_index() + 1)
					move_child(held_item, body.get_index() + 2)
					move_child(back_arm_hold,body.get_index() + 3)
				else:
					move_child(front_arm_hold,body.get_index() + 3)
					move_child(held_item, body.get_index() + 2)
					move_child(back_arm_hold,body.get_index() + 1)

				front_arm_hold.flip_h = false
				back_arm_hold.flip_h = false

			2: 
				#print("east")
				front_arm_hold.position = arm_pos_east[0]
				back_arm_hold.position = arm_pos_east[1]
				
				move_child(front_arm_hold,body.get_index() + 2)
				move_child(held_item, body.get_index() + 1)
				move_child(back_arm_hold,body.get_index() - 1)
				
				if aim_point.x < 0:
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = false
				else:
					front_arm_hold.flip_h = false
					back_arm_hold.flip_h = true

			3: 
				#print("southeast")
				front_arm_hold.position = arm_pos_southeast[0]
				back_arm_hold.position = arm_pos_southeast[1]
				
				move_child(front_arm_hold,body.get_index() + 2)
				move_child(held_item, body.get_index() + 1)
				move_child(back_arm_hold,body.get_index() - 1)
				
				front_arm_hold.texture.region = FRONT_ARM_FULL
				
				if aim_point.x < 0:
					front_arm_hold.position = Vector2(-arm_pos_southeast[0].x, arm_pos_southeast[0].y)
					back_arm_hold.position = Vector2(-arm_pos_southeast[1].x, arm_pos_southeast[1].y)
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = false
				else:
					front_arm_hold.flip_h = false
					back_arm_hold.flip_h = true

			1: 
				#print("northeast")
				front_arm_hold.texture.region = FRONT_ARM_MIN
				back_arm_hold.texture.region = BACK_ARM_MID
				
				move_child(front_arm_hold,body.get_index() + 2)
				move_child(held_item, body.get_index() - 2)
				move_child(back_arm_hold,body.get_index() - 1)
				
				back_arm_hold.visible = false
				
				if aim_point.x < 0:
					front_arm_hold.position = Vector2(-arm_pos_northeast[0].x, arm_pos_northeast[0].y)
					back_arm_hold.position = Vector2(-arm_pos_northeast[1].x, arm_pos_northeast[1].y)
					front_arm_hold.flip_h = true
					back_arm_hold.flip_h = true
				else:
					front_arm_hold.position = arm_pos_northeast[0]
					back_arm_hold.position = arm_pos_northeast[1]
					front_arm_hold.flip_h = false
					back_arm_hold.flip_h = true

		var rad_to_item = rad_to_deg(global_position.angle_to_point(held_item.global_position + offset))

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

