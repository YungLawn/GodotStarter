extends Sprite2D

const TURN_LIMIT: float = 0.33
@onready var back_leg = %back_leg
@onready var front_leg = %front_leg
@onready var back_arm = %back_arm
@onready var body = %body
@onready var front_arm = %front_arm
@onready var head = %head
@onready var hand_target = %hand_target
@onready var pivot_point = %pivot_point
@onready var label_2 = %Label2
@onready var face = %face

@onready var held_item = %held_item

var directional_indicator: String

func animate(direction: Vector2, look_direction: Vector2):
	determine_direction(direction.normalized(), look_direction.normalized())

	if look_direction.normalized().y < 0:
		face.visible = false
	else:
		face.visible = true

	if look_direction.normalized().x < 0:
		if look_direction.normalized().y < 0:
			move_child(front_leg, body.get_index() - 2)
			move_child(back_leg, body.get_index() - 1)
		else:
			move_child(front_leg, body.get_index() - 1)
			move_child(back_leg, body.get_index() - 2)

		var rot_mult = clamp(look_direction.normalized().x, -1, -0.25)
		front_leg.rotation_multiplier = rot_mult
		back_leg.rotation_multiplier = rot_mult
		#back_leg.position.y = clamp(abs(abs(look_direction.normalized().x) - 1) * 5, 2, 5)
	else:
		if look_direction.normalized().y < 0:
			move_child(front_leg, body.get_index() - 1)
			move_child(back_leg, body.get_index() - 2)
		else:
			move_child(front_leg, body.get_index() - 2)
			move_child(back_leg, body.get_index() - 1)
		var rot_mult = clamp(look_direction.normalized().x, 0.25, 1)
		front_leg.rotation_multiplier = rot_mult
		back_leg.rotation_multiplier = rot_mult
		#front_leg.position.y = clamp(abs(abs(look_direction.normalized().x) - 1) * 5, 2, 5)
		
	body.scale.x = abs(abs(look_direction.normalized().x * 0.5) - 1)
	head.position.x = look_direction.normalized().x
		
	face.position.x = look_direction.normalized().x * 4
	face.scale.x = clamp(abs(abs(look_direction.normalized().x) - 1), 0, 0.75)
	#face.scale.y = clamp(abs(abs(look_direction.normalized().x) - 1), 0.5, 0.6)

	front_arm.target = hand_target.position - front_arm.position
	front_arm.rotation_multiplier = look_direction.normalized().x
	front_arm.position.x = abs(abs(look_direction.normalized().x) - 1) * 3.75
	
	back_arm.target = hand_target.position - back_arm.position
	back_arm.rotation_multiplier = look_direction.normalized().x
	back_arm.position.x = abs(abs(look_direction.normalized().x) - 1) * -3.75
	
	front_leg.position.x = abs(abs(look_direction.normalized().x) - 1) * 1.75
	front_leg.direction = direction
	front_leg.step_offset = PI * 2

	back_leg.position.x = abs(abs(look_direction.normalized().x) - 1) * -1.75
	back_leg.direction = direction
	back_leg.step_offset = PI

	handle_hands(direction.normalized(), look_direction.normalized())

func determine_direction(direction: Vector2, look_direction: Vector2):
	if(look_direction.y > TURN_LIMIT):
		if abs(look_direction.x) > TURN_LIMIT:
			directional_indicator = "se"
		else: 
			directional_indicator = "s"
		
	if(look_direction.y < -TURN_LIMIT):
		if abs(look_direction.x) > TURN_LIMIT:
			directional_indicator = "ne"
		else: 
			directional_indicator = "n"
		
	if(abs(look_direction.y) < TURN_LIMIT):
		directional_indicator = "e"

func handle_hands(direction: Vector2, look_direction: Vector2):
	front_leg.back_pedal = false
	back_leg.back_pedal = false
	match directional_indicator:
		"n":
			#print("n")
			move_child(held_item, body.get_index() - 1)
			move_child(front_arm,body.get_index() - 1)
			move_child(back_arm,body.get_index() - 1)
		"s":
			#print("s")
			move_child(held_item, body.get_index() + 2)
			if direction.y < 0:
				front_leg.back_pedal = true
				back_leg.back_pedal = true
			if look_direction.x < 0:
				if direction.x > 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() + 3)
				move_child(back_arm,body.get_index() + 1)
			else:
				if direction.x < 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() + 1)
				move_child(back_arm,body.get_index() + 3)
		"e":
			#print("e")
			move_child(held_item, body.get_index() + 1)
			if look_direction.x < 0:
				if direction.x > 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() + 3)
				move_child(back_arm,body.get_index() + 1)
			else:
				if direction.x < 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() + 1)
				move_child(back_arm,body.get_index() + 3)
				
		"ne":
			#print("ne")
			move_child(held_item, body.get_index() - 1)
			if direction.y > 0:
				front_leg.back_pedal = true
				back_leg.back_pedal = true
			if look_direction.x < 0:
				if direction.x > 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() - 2)
				move_child(back_arm,body.get_index() + 1)
			else:
				if direction.x < 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() + 1)
				move_child(back_arm,body.get_index() - 2)
		"se":
			#print("se")
			move_child(held_item, body.get_index() + 1)
			if direction.y < 0:
				front_leg.back_pedal = true
				back_leg.back_pedal = true
			if look_direction.x < 0:
				if direction.x > 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() + 3)
				move_child(back_arm,body.get_index() + 1)
			else:
				if direction.x < 0:
					front_leg.back_pedal = true
					back_leg.back_pedal = true
				move_child(front_arm,body.get_index() + 1)
				move_child(back_arm,body.get_index() + 3)
