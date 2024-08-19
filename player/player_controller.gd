extends CharacterBody2D

signal toggle_inventory()

var rng = RandomNumberGenerator.new()

@onready var label = $Label
@onready var label_2 = $Label2
@onready var label_3 = $Label3

@onready var ik_back_arm = %ik_back_arm
@onready var ik_front_arm = %ik_front_arm

@onready var base_sprite = $BaseSprite
@onready var interact_ray = $Camera2D/interact_ray
@onready var health_label = $HealthLabel
@onready var hot_bar = $"../UI/HotBar"

@onready var held_item = %held_item
@onready var projectile_spawn_point = %projectile_spawn_point
@onready var attack_effect_spawn_point = %attack_effect_spawn_point
@onready var ranged_ray = %ranged_ray
@onready var melee_hit_area = %melee_hit_area
@onready var line_trail = %line_trail

@onready var pivot_point = %pivot_point
@onready var lock_on_zone = $lock_on_zone
@onready var collision_shape_2d = $lock_on_zone/CollisionShape2D

@onready var swing_start = $BaseSprite/swing_start
@onready var swing_peak = $BaseSprite/swing_peak
@onready var swing_end = $BaseSprite/swing_end

@export var inventorydata: InventoryData
@export var equip_inventorydata: InventoryDataEquip
@export var SPEED: float = 50

var SPEED_MULTIPLER: float = 1.0
var can_move: bool = true
var can_look: bool = true

var can_lock_on: bool = true
var targets_in_range: Array
var locked_target_index: int = 0

var is_pressed: bool
var can_press: bool = true

var health: int = 0
var hands_empty: bool = true
var held_item_data: ItemData
var held_item_weight: float = 0.0
var item_rotation_flipper: int
var item_position_flipper: int
var lerp_strength: float = 0.1

var direction: Vector2 = Vector2(0,0)

var swing_size: float

var test_bool: bool

#func _ready():
	#PlayerManager.player = self
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_pressed = true
			else:
				is_pressed = false
	if Input.is_action_just_pressed("right click"):
		#print("!!")
		can_lock_on = not can_lock_on
		#print(can_lock_on)
		
	if Input.is_action_just_pressed("inventory_action"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("reload"):
		if held_item_data.has_method("reload"):
			held_item_data.reload(self, item_position_flipper)
	if Input.is_action_just_pressed("test1"):
		#pass
		$BaseSprite/Body.offset.y -= 1
		$BaseSprite/Body.position.y += 1
	if Input.is_action_just_pressed("test2"):
		#pass
		$BaseSprite/Body.offset.y += 1
		$BaseSprite/Body.position.y -= 1
	if targets_in_range:
		if Input.is_action_just_pressed("cycle_target_up"): #e
			if locked_target_index == targets_in_range.size() - 1:
				locked_target_index = 0
			else:
				locked_target_index += 1
		if Input.is_action_just_pressed("cycle_target_down"): #q
			if locked_target_index == 0:
				locked_target_index = targets_in_range.size() - 1
			else:
				locked_target_index -= 1
	else: locked_target_index = 0

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
		
func heal(heal_value: int) -> void:
	var random_number = randf_range(-1, 1)
	if held_item_data.has_method("heal"):
		var tween = create_tween().set_parallel(true)
		tween.tween_property(held_item, "rotation", held_item.rotation + (random_number * 1.5), 0.15).set_ease(Tween.EASE_OUT)
		tween.tween_property(base_sprite, "modulate", base_sprite.modulate, 0.15).from(Color(2,2,2,1)).set_ease(Tween.EASE_OUT)
		health += heal_value

func _physics_process(delta):
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	
	velocity = lerp(velocity, direction.normalized() * (SPEED * SPEED_MULTIPLER), delta * 50)
	#velocity = direction.normalized() * (SPEED * SPEED_MULTIPLER)
	move_and_slide()

func _process(delta):
	#print((Crosshair.global_position - global_position).normalized(), get_local_mouse_position().normalized())

	lerp_strength = delta * (35- (held_item_weight * 5))

	#handle_lock_on(delta)
	
	if held_item_data:
		handle_held_item(delta)
		
	base_sprite.animate(direction, Crosshair.global_position - pivot_point.global_position)
	base_sprite.handle_hands(hands_empty, Crosshair.global_position - pivot_point.global_position, held_item.position)

func handle_held_item(delta):
	var local_item_pos: Vector2
	var local_item_rot: float
	
	held_item.offset.y = item_position_flipper * (held_item_data.hold_offset.y - 0.5)
	held_item.offset.x = held_item_data.hold_offset.x

	if held_item_data.has_method("attack"):
		if (Crosshair.global_position - pivot_point.global_position).normalized().x < 0:
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
			local_item_pos = get_point_on_radius(pivot_point.global_position, Crosshair.global_position,
				(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)

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
				SPEED_MULTIPLER = 0.1
				direction = (Crosshair.global_position - global_position)
			else:
				SPEED_MULTIPLER = lerp(SPEED_MULTIPLER, 1.0, lerp_strength)
			handle_swing_plane()
			ranged_ray.enabled = false
			melee_hit_area.monitoring = true
			#melee_hit_area.position = Vector2(held_item_data.effective_range * 0.4, held_item_data.effective_range * 0.5 * item_position_flipper)
			melee_hit_area.position = Vector2(held_item_data.hit_point.x, held_item_data.hit_point.y * item_position_flipper)
			swing_size = (0.15 * item_rotation_flipper) * PI  
			local_item_rot = rad_to_deg((held_item.global_position - Vector2(0, held_item_data.hold_offset.y))
				.angle_to_point(Crosshair.global_position)) - (held_item_data.rotation_offset * item_rotation_flipper)
			local_item_pos = get_point_on_radius(base_sprite.global_position, Crosshair.global_position, 
				(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)

	else:
		local_item_pos = get_point_on_radius(pivot_point.global_position, Crosshair.global_position,
			(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)
		held_item.rotation = 0
		held_item.flip_v = false
		ranged_ray.enabled = false
		melee_hit_area.monitoring = false

	#held_item.rotation_degrees = local_item_rot
	held_item.rotation = lerp_angle(held_item.rotation, deg_to_rad(local_item_rot), lerp_strength * 0.5)
	#held_item.position = local_item_pos
	held_item.position =  lerp(held_item.position, local_item_pos, lerp_strength * 2) 

func handle_lock_on(delta):
	if held_item_data.has_method("attack"):
		collision_shape_2d.shape.radius = held_item_data.effective_range
	else:
		collision_shape_2d.shape.radius = 20

	if can_lock_on and !hands_empty:
		lock_on_zone.monitoring = true
		Crosshair.modulate = lerp(Crosshair.modulate, Color(1,1,0,0.75), delta * 10)
	else:
		lock_on_zone.monitoring = false
		Crosshair.modulate = lerp(Crosshair.modulate, Color(1,1,1,0.75), delta * 10)

	if targets_in_range:
		for target in targets_in_range:
			if targets_in_range.find(target) == locked_target_index:
				target.indicator.modulate = lerp(target.indicator.modulate, Color(1,1,0,0.75), delta * 10)
			else:
				target.indicator.modulate = lerp(target.indicator.modulate, Color(1,1,1,0.75), delta * 10)

func handle_swing_plane():
	swing_start.position = get_point_on_radius(pivot_point.global_position, Crosshair.global_position, 
		(swing_size ), held_item_data.hold_distance)
	swing_peak.position = get_point_on_radius(pivot_point.global_position, Crosshair.global_position,  
		0.0 * item_rotation_flipper, held_item_data.hold_distance * 1.1)
	swing_end.position = get_point_on_radius(pivot_point.global_position, Crosshair.global_position, 
		(-swing_size), held_item_data.hold_distance * 0.9)

func get_point_on_radius(center: Vector2, direction: Vector2, rotation_offset: float, radius):
	var radian: float = (center).angle_to_point(direction) - rotation_offset
	return Vector2(radius * cos(radian), radius * sin(radian))
	
func _on_hot_bar_set_selected_slot(index):
	#print("!!")
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

func _on_lock_on_zone_area_entered(area):
	if area.get_parent().is_in_group("damageable") and !area.get_parent() in targets_in_range:
		area.get_parent().indicator.modulate.a = lerp(area.get_parent().indicator.modulate.a, 0.75, lerp_strength)
		targets_in_range.push_back(area.get_parent())

func _on_lock_on_zone_area_exited(area):
	area.get_parent().indicator.modulate.a = lerp(area.get_parent().indicator.modulate.a, -3.5, lerp_strength)
	targets_in_range.pop_at(targets_in_range.find(area.get_parent()))
	if targets_in_range.size() < 2:
		locked_target_index = 0
