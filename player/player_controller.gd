extends CharacterBody2D

signal toggle_inventory()

var rng = RandomNumberGenerator.new()
const SMOKE = preload("res://assets/FX/smoke.tscn")

@onready var label = $Label
@onready var label_2 = $Label2
@onready var label_3 = $Label3

@onready var base_sprite = $BaseSprite
@onready var interact_ray = $Camera2D/interact_ray
@onready var health_label = $HealthLabel
@onready var hot_bar = $"../UI/HotBar"
@onready var held_item = $BaseSprite/held_item
@export var inventorydata: InventoryData
@export var equip_inventorydata: InventoryDataEquip
@onready var ammo_count = $ammo_count
@onready var projectile_spawn_point = $BaseSprite/held_item/projectile_spawn_point
@onready var attack_effect_spawn_point = $BaseSprite/held_item/attack_effect_spawn_point
@onready var ranged_ray = $BaseSprite/held_item/ranged_ray
@onready var melee_hit_area = $BaseSprite/held_item/melee_hit_area
@onready var line_trail = $BaseSprite/held_item/melee_hit_area/line_trail

@onready var aim_point = $aim_point
@onready var lock_on_zone = $lock_on_zone
@onready var collision_shape_2d = $lock_on_zone/CollisionShape2D

@onready var back_swing = $BaseSprite/back_swing
@onready var back_step = $BaseSprite/back_step
@onready var peak_swing = $BaseSprite/peak_swing
@onready var forward_step = $BaseSprite/forward_step
@onready var forward_swing = $BaseSprite/forward_swing

@export var SPEED: float = 50
var can_move: bool = true
var can_look: bool = true

var can_lock_on: bool = true
var targets_in_range: Array
var locked_target_index: int = 0

var is_pressed: bool
var can_press: bool = true

var health: int = 5
var hands_empty: bool = true
var held_item_data: ItemData
var held_item_weight: float = 0.0
var item_rotation_offset: float
var item_rotation_flipper: int
var item_position_flipper: int
var lerp_strength: float

var direction: Vector2 = Vector2(0,0)
var lookDirection: Vector2 = Vector2(0,0)

var swing_size: float

func _ready():
	PlayerManager.player = self
	aim_point.global_position = global_position
	
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
		print(can_lock_on)
		
	if Input.is_action_just_pressed("inventory_action"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("reload"):
		if held_item_data.has_method("reload"):
			held_item_data.reload(self)
	#if Input.is_action_just_pressed("test1"):
		#print("test")
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
	health += heal_value
	if held_item_data.has_method("heal"):
		var tween = create_tween()
		tween.tween_property(held_item, "rotation", held_item.rotation + (random_number * 1.5), 0.15).set_ease(Tween.EASE_OUT)
		tween.tween_property(base_sprite, "modulate", base_sprite.modulate, 0.15).from(Color(2,2,2,1)).set_ease(Tween.EASE_OUT)

func weapon_fired():
	var smoke = SMOKE.instantiate()
	get_tree().root.add_child(smoke)
	smoke.global_position = attack_effect_spawn_point.global_position
	smoke.rotation = projectile_spawn_point.rotation
	smoke.amount = (held_item_data.recoil_strength.x) * 2
	smoke.process_material.scale_max = (held_item_data.recoil_strength.x)
	smoke.process_material.initial_velocity_max = (held_item_data.recoil_strength.x) * 10
	smoke.emitting = true
	smoke.finished.connect(func (): smoke.queue_free() )

func bezier(t, p0, p1, p2):
	var q0 = p0.lerp(p1, 1 -pow(1 - t, 3))
	var q1 = p1.lerp(p2, 1 -pow(1 - t, 3))
	var r = q0.lerp(q1, 1 - pow(1 - t, 3))
	return r
	
func swing(swing_speed, item):
	#print(held_item_data.swing_time)
	#time += swing_speed
	if held_item_data.swing_time == 0:
		item.position = lerp(item.position, back_swing.position, 0.1)
	
	item.position = bezier(held_item_data.swing_time, 
		back_swing.position, peak_swing.position, forward_step.position)
	
	if held_item_data.swing_forward:
		if held_item_data.swing_time < 0.99:
			held_item_data.can_damage = true
			held_item_data.swing_time += swing_speed 
			#held_item.rotation += held_item_data.swing_time * 2
		else:
			#held_item_data.swing_time = 0
			held_item_data.swinging = false
			held_item_data.can_damage = false
			held_item_data.swing_forward = false
			held_item_data.swing_backward = true
			
	elif held_item_data.swing_backward:
		if held_item_data.swing_time > 0.01:
			held_item_data.swing_time -= swing_speed 
			#held_item.rotation += held_item_data.swing_time * 2
		else:
			held_item_data.swing_forward = true
			held_item_data.swing_backward = false
	#if swing_forward:
		#if time < 0.99:
			#time += swing_speed 
			#item.rotation += swing_speed * 1.75
			##print(pow(2, -10 * time))
		#else:
			#item.rotation_degrees = 90
			#item.flip_h = true
			#swing_forward = false
			#swing_backward = true

	#elif swing_backward:
		#if time > 0.01:
			#time -= swing_speed
			#item.rotation -= swing_speed * 1.75
		#else:
			#item.rotation_degrees = -90
			#item.flip_h = false
			#swing_forward = true
			#swing_backward = false

func _physics_process(delta):
	velocity = direction.normalized() * SPEED
	move_and_slide()

func _process(delta):
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	lookDirection = get_local_mouse_position()
	base_sprite.animate(direction, aim_point.position)

	lerp_strength = delta * (35	 - (held_item_weight * 5))
	handle_aim_point(delta, lerp_strength)
	
	if held_item_data:
		handle_held_item(delta)

func handle_held_item(delta):
	line_trail.pos = melee_hit_area.global_position
	held_item.position =  lerp(held_item.position, (aim_point.position.normalized() * held_item_data.hold_distance) - held_item_data.offset, lerp_strength * 2.25)
	base_sprite.handle_hands(held_item_data.offset + held_item_data.hand_offset, hands_empty, aim_point.position)

	if aim_point.position.normalized().y < 0:
		held_item.z_index = 0
	else: held_item.z_index = 1

	if held_item_data.has_method("attack"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		if aim_point.position.normalized().x < 0:
			held_item.flip_v = true
			item_rotation_flipper = -1
			item_position_flipper = 1
		else:
			held_item.flip_v = false
			item_rotation_flipper = 1
			item_position_flipper = -1
			
		held_item.offset.y = held_item_data.offset.y * 0.5 * item_position_flipper
		item_rotation_offset = held_item_data.rotation_offset * item_rotation_flipper
		var item_pos_rad = (aim_point.position + (held_item_data.offset * 2) ).angle()
		#held_item.rotation = lerp(held_item.rotation, item_pos_rad - item_rotation_offset, lerp_strength)
		held_item.rotation = item_pos_rad - item_rotation_offset
		
		handle_lock_on(delta, lerp_strength)
		if(held_item_data.has_method("shoot")):
			projectile_spawn_point.position.y = held_item_data.offset.y * 0.75  * item_position_flipper
			attack_effect_spawn_point.position.y = held_item_data.offset.y * 0.75  * item_position_flipper
			ranged_ray.position.y = held_item_data.offset.y * 0.5  * item_position_flipper
			melee_hit_area.monitoring = false
			ranged_ray.enabled = true
			ranged_ray.target_position.x = held_item_data.muzzle_velocity * 0.025 if held_item_data.muzzle_velocity < 3250 else position.distance_to(aim_point)
			projectile_spawn_point.position.x = -held_item_data.muzzle_flash_offset * 1.5
			attack_effect_spawn_point.position.x = held_item_data.muzzle_flash_offset
			projectile_spawn_point.rotation = held_item.rotation
		elif(held_item_data.has_method("swing")):
			melee_hit_area.position = Vector2(held_item_data.effective_range * 0.3, held_item_data.effective_range * 0.4 * item_position_flipper)
			#melee_hit_area.rotation_degrees = 45 * item_rotation_flipper
			swing_size = (0.3 * item_rotation_flipper) * PI  
			ranged_ray.enabled = false
			melee_hit_area.monitoring = true
			handle_swing_plane()
	else:
		held_item.rotation = 0
		ranged_ray.enabled = false
		melee_hit_area.monitoring = false

func handle_aim_point(delta, lerp_strength):
	if !targets_in_range:
		if held_item_data.has_method("attack"):
			if held_item_data.has_method("shoot") and held_item_data.can_reload:
				if held_item.position.distance_to(lookDirection - held_item_data.offset) < held_item_data.effective_range * 0.9:
					if held_item.position.distance_to(lookDirection - held_item_data.offset) < 40:
						aim_point.position = lerp(aim_point.position, lookDirection.normalized() * 50, lerp_strength)
					else:
						aim_point.position = lerp(aim_point.position, lookDirection, lerp_strength)
				else:
					aim_point.position = lerp(aim_point.position, lookDirection.normalized() * held_item_data.effective_range, lerp_strength * 0.35)
					
			elif held_item_data.has_method("swing"):
				aim_point.position = lerp(aim_point.position, lookDirection.normalized() * held_item_data.effective_range, lerp_strength)
		else:
			aim_point.position = lerp(aim_point.position, lookDirection.normalized() * 20, lerp_strength)
	else:
		aim_point.global_position = lerp(aim_point.global_position, targets_in_range[locked_target_index].global_position, lerp_strength * pow(0.5,2))

func handle_lock_on(delta, lerp_strength):
	collision_shape_2d.shape.radius = held_item_data.effective_range * 0.975
	if can_lock_on and !hands_empty:
		lock_on_zone.monitoring = true
		aim_point.modulate = lerp(aim_point.modulate, Color(1,1,0,0.75), delta * 10)
	else:
		lock_on_zone.monitoring = false
		aim_point.modulate = lerp(aim_point.modulate, Color(1,1,1,0.75), delta * 10)

	if targets_in_range:
		for target in targets_in_range:
			if targets_in_range.find(target) == locked_target_index:
				target.indicator.modulate = lerp(target.indicator.modulate, Color(1,1,0,0.75), delta * 10)
			else:
				target.indicator.modulate = lerp(target.indicator.modulate, Color(1,1,1,0.75), delta * 10)

func handle_swing_plane():
	var back_rad = deg_to_rad(held_item.rotation_degrees + item_rotation_offset) - swing_size
	var back_step_rad = deg_to_rad(held_item.rotation_degrees + item_rotation_offset) - (swing_size * 0.5)
	var peak_rad = deg_to_rad(held_item.rotation_degrees + item_rotation_offset)
	var front_step_rad = deg_to_rad(held_item.rotation_degrees + item_rotation_offset) + (swing_size * 0.5)
	var front_rad = deg_to_rad(held_item.rotation_degrees + item_rotation_offset) + swing_size
	
	var radius_back = held_item_data.hold_distance * 1
	var radius_back_step = held_item_data.hold_distance * 1
	var radius_peak = held_item_data.hold_distance * 1.5
	var radius_front_step = held_item_data.hold_distance * 1
	var radius_front = held_item_data.hold_distance * 1

	back_swing.position = Vector2(radius_back * cos(back_rad), radius_back * sin(back_rad)) - held_item_data.offset
	back_step.position = Vector2(radius_back_step * cos(back_step_rad), radius_back_step * sin(back_step_rad)) - held_item_data.offset
	peak_swing.position = Vector2(radius_peak * cos(peak_rad), radius_peak * sin(peak_rad)) - held_item_data.offset
	forward_step.position = Vector2(radius_front_step * cos(front_step_rad), radius_front_step * sin(front_step_rad)) - held_item_data.offset
	forward_swing.position = Vector2(radius_front * cos(front_rad), radius_front * sin(front_rad)) - held_item_data.offset

func _on_hot_bar_set_selected_slot(index):
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
		area.get_parent().indicator.modulate = lerp(area.get_parent().indicator.modulate, Color(1,1,0,0.75), lerp_strength)
		targets_in_range.push_back(area.get_parent())

func _on_lock_on_zone_area_exited(area):
	area.get_parent().indicator.modulate = lerp(area.get_parent().indicator.modulate, Color(0,0,0,0.0), lerp_strength)
	targets_in_range.pop_at(targets_in_range.find(area.get_parent()))
	if targets_in_range.size() < 2:
		locked_target_index = 0



