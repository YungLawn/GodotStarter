extends CharacterBody2D

signal toggle_inventory()

@onready var main_sprite = $main_sprite
@onready var front_arm = %front_arm
@onready var back_arm = %back_arm
@onready var body = %body
@onready var head = %head
@onready var front_leg = %front_leg
@onready var back_leg = %back_leg
@onready var hand_target = %hand_target
@onready var pivot_point = %pivot_point

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

var direction: Vector2
var look_direction: Vector2
var walk_speed: float = 7.0
var SPEED_MULTIPLER: float = 1.0

var is_pressed: bool
var can_press: bool = true

var health: int = 0
var hands_empty: bool = true
var held_item_data: ItemData
var held_item_weight: float = 0.0
var item_rotation_flipper: int
var item_position_flipper: int
var lerp_strength: float = 0.1

@onready var swing_start = %swing_start
@onready var swing_peak = %swing_peak
@onready var swing_end = %swing_end
var swing_size: float

func _ready():
	PlayerManager.player = self

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_pressed = true
			else:
				is_pressed = false
	if Input.is_action_just_pressed("inventory_action"):
		#pass
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("reload"):
		if held_item_data.has_method("reload"):
			held_item_data.reload(self, item_position_flipper)

func interact() -> void:
	pass
	#if interact_ray.is_colliding():
		#interact_ray.get_collider().player_interact()
		
func heal(heal_value: int) -> void:
	var random_number = randf_range(-1, 1)
	if held_item_data.has_method("heal"):
		var tween = create_tween().set_parallel(true)
		tween.tween_property(held_item, "rotation", held_item.rotation + (random_number * 1.5), 0.15).set_ease(Tween.EASE_OUT)
		tween.tween_property(main_sprite, "modulate", main_sprite.modulate, 0.15).from(Color(2,2,2,1)).set_ease(Tween.EASE_OUT)
		health += heal_value
		
func get_point_on_radius(center: Vector2, direction: Vector2, rotation_offset: float, radius):
	var radian: float = (center).angle_to_point(direction) - rotation_offset
	return Vector2(radius * cos(radian), radius * sin(radian))

func _physics_process(delta):
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	look_direction = Crosshair.global_position - pivot_point.global_position
	
	velocity = lerp(velocity, direction.normalized() * walk_speed * 7.0, 0.05)

	move_and_slide()
	
func _process(delta):
	front_leg.walk_speed = walk_speed
	back_leg.walk_speed = walk_speed
	#label.text = str(abs(abs(look_direction.normalized().x) - 1))
	label.text = str(direction.normalized())
	label_2.text = str(front_leg.rotation_multiplier)
	
	hand_target.position = held_item.position
	lerp_strength = delta * (35- (held_item_weight * 5))
	
	if held_item_data:
		handle_held_item(delta)
		
	main_sprite.animate(direction, look_direction)
	
	
func handle_held_item(delta):
	var local_item_pos: Vector2
	var local_item_rot: float
	
	held_item.offset.y = item_position_flipper * (held_item_data.hold_offset.y - 0.5)
	held_item.offset.x = held_item_data.hold_offset.x

	if held_item_data.has_method("attack"):
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
		
		if(held_item_data.has_method("shoot")):
			local_item_rot = rad_to_deg((held_item.global_position - Vector2(0, held_item_data.hold_offset.y))
				.angle_to_point(Crosshair.global_position))
			local_item_pos = pivot_point.position + get_point_on_radius(pivot_point.global_position, Crosshair.global_position,
				(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)
			#local_item_pos = pivot_point.position + look_direction.normalized() * held_item_data.hold_distance

			melee_hit_area.monitoring = false
			ranged_ray.enabled = true
			ranged_ray.target_position.x = held_item_data.muzzle_velocity * 0.015
			ranged_ray.position.y = item_position_flipper
			attack_effect_spawn_point.position.y = held_item_data.hold_offset.y * item_position_flipper
			attack_effect_spawn_point.position.x = held_item_data.muzzle_flash_offset + held_item_data.hold_offset.x
			projectile_spawn_point.position.x = attack_effect_spawn_point.position.x - 10
			projectile_spawn_point.position.y = held_item_data.hold_offset.y * item_position_flipper
			
		elif(held_item_data.has_method("swing")):
			if held_item_data.is_attacking:
				direction = look_direction.normalized()
				velocity = look_direction.normalized() * 10
			handle_swing_plane()
			ranged_ray.enabled = false
			melee_hit_area.monitoring = true
			#melee_hit_area.position = Vector2(held_item_data.effective_range * 0.4, held_item_data.effective_range * 0.5 * item_position_flipper)
			melee_hit_area.position = Vector2(held_item_data.hit_point.x, held_item_data.hit_point.y * item_position_flipper)
			swing_size = (0.15 * item_rotation_flipper) * PI  
			local_item_rot = rad_to_deg((held_item.global_position - Vector2(0, held_item_data.hold_offset.y))
				.angle_to_point(Crosshair.global_position)) - (held_item_data.rotation_offset * item_rotation_flipper)
			local_item_pos = pivot_point.position + get_point_on_radius(pivot_point.global_position, Crosshair.global_position, 
				(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)
			#local_item_pos = pivot_point.position + look_direction.normalized() * held_item_data.hold_distance

	else:
		local_item_pos = pivot_point.position +  get_point_on_radius(pivot_point.global_position, Crosshair.global_position,
			(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)
		held_item.rotation = 0
		held_item.flip_v = false
		ranged_ray.enabled = false
		melee_hit_area.monitoring = false

	#held_item.rotation_degrees = local_item_rot
	held_item.rotation = lerp_angle(held_item.rotation, deg_to_rad(local_item_rot), lerp_strength * 0.5)
	#held_item.position = local_item_pos
	held_item.position =  lerp(held_item.position, local_item_pos, lerp_strength * 2) 
	
func handle_swing_plane():
	swing_start.position = pivot_point.position + get_point_on_radius(pivot_point.global_position, Crosshair.global_position, 
		(swing_size ), held_item_data.hold_distance)
	swing_peak.position = pivot_point.position + get_point_on_radius(pivot_point.global_position, Crosshair.global_position,  
		0.0 * item_rotation_flipper, held_item_data.hold_distance * 1.1)
	swing_end.position = pivot_point.position + get_point_on_radius(pivot_point.global_position, Crosshair.global_position, 
		(-swing_size), held_item_data.hold_distance * 0.9)
	
func _on_hot_bar_set_selected_slot(index):
	#print("!!!")
	if inventorydata.slot_datas[index]:
		held_item_data = inventorydata.slot_datas[index].item_data
		hands_empty = false
		held_item.texture = held_item_data.texture
		held_item_weight = held_item_data.weight
	else:
		hands_empty = true
		held_item.texture = null
		
func _on_melee_hit_area_area_entered(area):
	if(held_item_data.has_method("swing")):	
		if held_item_data.can_damage and area.get_parent().is_in_group("damageable"):
			#print(area.get_parent().is_in_group("damageable"))
			held_item_data.do_damage(area.get_parent())
