extends CharacterBody2D

signal toggle_inventory()

@onready var player_input_handler: Node2D = %player_input_handler
@onready var state_chart: StateChart = $StateChart

@onready var main_sprite = $main_sprite
@onready var front_arm = %front_arm
@onready var back_arm = %back_arm
@onready var body = %body
@onready var head = %head
@onready var front_leg = %front_leg
@onready var back_leg = %back_leg
@onready var hand_target = %hand_target
@onready var pivot_point = %pivot_point
@onready var interaction_zone: Area2D = %interaction_zone

@onready var held_item = %held_item
@onready var projectile_spawn_point = %projectile_spawn_point
@onready var attack_effect_spawn_point = %attack_effect_spawn_point
@onready var ranged_ray = %ranged_ray
@onready var melee_hit_area = %melee_hit_area
@onready var line_trail = %line_trail

@onready var label = $Label
@onready var label_2 = $Label2

@export var inventorydata: InventoryData
@export var equip_inventorydata: InventoryDataEquip
var inventory_open: bool

var direction: Vector2
var look_direction: Vector2
var walk_speed: float = 7.0
var SPEED_MULTIPLER: float = 1.0

var is_pressed: bool
var can_press: bool = true

var health: int = 0
var held_item_data: ItemData
var item_rotation_flipper: int
var item_position_flipper: int
var lerp_strength: float = 0.1

@onready var swing_start = %swing_start
@onready var swing_peak = %swing_peak
@onready var swing_end = %swing_end
var swing_size: float

var accuracy_multiplier: float = 5.0

func interact() -> void:
	if interaction_zone.get_overlapping_areas():
		if interaction_zone.get_overlapping_areas()[0].get_parent().is_in_group("external_inventory"):
			interaction_zone.get_overlapping_areas()[0].get_parent().player_interact()

func _process(delta):
	main_sprite.animate(direction, look_direction)

func _on_walk_state_entered() -> void:
	front_leg.walk_speed = walk_speed
	back_leg.walk_speed = walk_speed

func _on_walk_state_physics_processing(delta: float) -> void:
	velocity = direction.normalized() * walk_speed * 7.0
	
	if direction == Vector2.ZERO:
		state_chart.send_event("to_idle")

	move_and_slide()

func _on_idle_state_entered() -> void:
	velocity = Vector2.ZERO

func _on_idle_state_processing(delta: float) -> void:
	if direction != Vector2.ZERO:
		state_chart.send_event("to_walk") 

func _on_hands_empty_state_entered() -> void:
	held_item_data = null
	held_item.texture = null
	hand_target.position = interaction_zone.position - main_sprite.position

func _on_hands_empty_state_processing(delta: float) -> void:
	if held_item_data:
		print("!!")

func _on_held_item_state_processing(delta: float) -> void:
	hand_target.position = held_item.position
	lerp_strength = (delta * (35 - (held_item_data.weight * 5)))
	
	if held_item_data.rotatable:
		if (look_direction).normalized().x < 0:
			#held_item.scale.y = lerp(held_item.scale.y, -1.0, delta * 20)
			held_item.flip_v = true
			item_rotation_flipper = -1
			item_position_flipper = 1
		else:
			#held_item.scale.y = lerp(held_item.scale.y, 1.0, delta * 20)
			held_item.flip_v = false
			item_rotation_flipper = 1
			item_position_flipper = -1
	
	var local_item_pos: Vector2
	var local_item_rot: float
	held_item.offset.y = item_position_flipper * (held_item_data.hold_offset.y - 0.5)
	held_item.offset.x = held_item_data.hold_offset.x
	
	local_item_rot = rad_to_deg((held_item.position - Vector2(0, held_item_data.hold_offset.y  + pivot_point.position.y))
		.angle_to_point(look_direction)) - (held_item_data.rotation_offset * item_rotation_flipper)
	
	local_item_pos = pivot_point.position + get_point_on_radius(pivot_point.position, look_direction,
	(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)
	
	#held_item.rotation_degrees = local_item_rot
	held_item.rotation = lerp_angle(held_item.rotation, deg_to_rad(local_item_rot), lerp_strength * 0.5)
	#held_item.position = local_item_pos
	held_item.position =  lerp(held_item.position, local_item_pos, lerp_strength * 5) 
	
	if held_item_data.has_method("shoot"):
		state_chart.send_event("to_ranged_item")
	elif held_item_data.has_method("swing"):
		state_chart.send_event("to_melee_item")
	else: 
		state_chart.send_event("to_static_item")	

func _on_ranged_item_state_processing(delta: float) -> void:
	melee_hit_area.monitoring = false
	ranged_ray.enabled = true
	ranged_ray.target_position.x = held_item_data.muzzle_velocity * 0.0175
	ranged_ray.position.y = held_item_data.hold_offset.y * item_position_flipper
	attack_effect_spawn_point.position.y = held_item_data.hold_offset.y * item_position_flipper
	attack_effect_spawn_point.position.x = held_item_data.muzzle_flash_offset + held_item_data.hold_offset.x
	projectile_spawn_point.position.x = attack_effect_spawn_point.position.x - accuracy_multiplier
	projectile_spawn_point.position.y = held_item_data.hold_offset.y * item_position_flipper

func _on_melee_item_state_processing(delta: float) -> void:
	if held_item_data.is_attacking:
		direction = look_direction.normalized()
		velocity = look_direction.normalized() * 10
	handle_swing_plane()
	ranged_ray.enabled = false
	melee_hit_area.monitoring = true
	melee_hit_area.position = Vector2(held_item_data.hit_point.x, held_item_data.hit_point.y * item_position_flipper)
	swing_size = (0.15 * item_rotation_flipper) * PI  

func _on_static_item_state_processing(delta: float) -> void:
	held_item.rotation = 0
	held_item.flip_v = false
	ranged_ray.enabled = false
	melee_hit_area.monitoring = false

func handle_swing_plane():
	swing_start.position = pivot_point.position + get_point_on_radius(pivot_point.position, look_direction, 
		(swing_size ), held_item_data.hold_distance)
	swing_peak.position = pivot_point.position + get_point_on_radius(pivot_point.position, look_direction,  
		0.0 * item_rotation_flipper, held_item_data.hold_distance * 1.1)
	swing_end.position = pivot_point.position + get_point_on_radius(pivot_point.position, look_direction, 
		(-swing_size), held_item_data.hold_distance * 0.9)

func get_point_on_radius(center: Vector2, direction: Vector2, rotation_offset: float, radius):
	var radian: float = (center).angle_to_point(direction) - rotation_offset
	return Vector2(radius * cos(radian), radius * sin(radian))

func set_selected_item(index: int):
	#print("selected")
	if inventorydata.slot_datas[index]:
		held_item_data = inventorydata.slot_datas[index].item_data
		held_item.texture = held_item_data.texture
		state_chart.send_event("to_held_item")
	else:
		state_chart.send_event("to_hands_empty")
		
func _on_melee_hit_area_area_entered(area):
	if(held_item_data.has_method("swing")):	
		if held_item_data.can_damage and area.get_parent().is_in_group("damageable"):
			#print(area.get_parent().is_in_group("damageable"))
			held_item_data.do_damage(area.get_parent())
