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
@onready var hold_point = $BaseSprite/hold_point
@onready var projectile_spawn_point = $BaseSprite/held_item/projectile_spawn_point
@onready var attack_effect_spawn_point = $BaseSprite/held_item/attack_effect_spawn_point
@onready var ranged_ray = $BaseSprite/held_item/ranged_ray
@onready var melee_hit_area = $BaseSprite/held_item/melee_hit_area
@onready var line_trail = $BaseSprite/held_item/melee_hit_area/line_trail
@export var inventorydata: InventoryData
@export var equip_inventorydata: InventoryDataEquip

@onready var aim_point = $aim_point
@onready var lock_on_zone = $lock_on_zone
@onready var collision_shape_2d = $lock_on_zone/CollisionShape2D

@onready var swing_start = $BaseSprite/swing_start
@onready var swing_peak = $BaseSprite/swing_peak
@onready var swing_end = $BaseSprite/swing_end

@onready var hand_swing_start = $BaseSprite/hand_swing_start
@onready var hand_swing_peak = $BaseSprite/hand_swing_peak
@onready var hand_swing_end = $BaseSprite/hand_swing_end

@export var SPEED: float = 50
var SPEED_MULTIPLER: float = 1.0
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
var item_rotation_flipper: int
var item_position_flipper: int
var lerp_strength: float

var direction: Vector2 = Vector2(0,0)
var lookDirection: Vector2 = Vector2(0,0)

var swing_size: float

var test_bool: bool

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
		#print(can_lock_on)
		
	if Input.is_action_just_pressed("inventory_action"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("reload"):
		if held_item_data.has_method("reload"):
			held_item_data.reload(self)
	#if Input.is_action_just_pressed("test1"):
		#print("test")
	if Input.is_action_just_pressed("test1"):
		held_item.rotation += 5
		label.text = str(held_item.rotation_degrees)
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

func _physics_process(delta):
	velocity = direction.normalized() * (SPEED * SPEED_MULTIPLER)
	move_and_slide()

func _process(delta):
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	lookDirection = get_local_mouse_position()

	lerp_strength = delta * (35- (held_item_weight * 5))

	handle_aim_point(delta, lerp_strength)
	handle_lock_on(delta, lerp_strength)
	
	if held_item_data:
		handle_held_item(delta)
		
	base_sprite.animate(direction, aim_point.position, SPEED_MULTIPLER)
	base_sprite.handle_hands(hands_empty, hold_point.position, aim_point.position)

func handle_held_item(delta):
	#base_sprite.handle_hands(hands_empty, hold_point.position, aim_point.position)
	line_trail.pos = melee_hit_area.global_position
	var local_item_pos: Vector2
	var local_item_rot: float
	var local_hold_point: Vector2
	var local_lerp_strength: float
	if aim_point.position.normalized().y < 0:
		held_item.z_index = 0
	else: held_item.z_index = 1

	if held_item_data.has_method("attack"):
		if aim_point.position.normalized().x < 0:
			held_item.flip_v = true
			item_rotation_flipper = -1
			item_position_flipper = 1
		else:
			held_item.flip_v = false
			item_rotation_flipper = 1
			item_position_flipper = -1
		
		if(held_item_data.has_method("shoot")):
			held_item.offset = Vector2.ZERO
			local_item_rot = rad_to_deg(held_item.global_position.angle_to_point((aim_point.global_position + Vector2(0,1)))) - (held_item_data.rotation_offset * item_rotation_flipper)
			local_item_pos = get_point_on_radius(position, aim_point.global_position,
				(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)
			local_hold_point = get_point_on_radius(position, aim_point.global_position, 
				(held_item_data.hold_point_offset * clamp(abs(aim_point.position.normalized().x), 0.05, 1) * item_position_flipper) * PI,
			 		held_item_data.hold_distance * 2)
			
			melee_hit_area.monitoring = false
			ranged_ray.enabled = true
			ranged_ray.target_position.x = held_item_data.muzzle_velocity * 0.015 if held_item_data.muzzle_velocity < 3250 else position.distance_to(aim_point.position)
			ranged_ray.position.y = item_position_flipper * 1
			projectile_spawn_point.position.y = item_position_flipper
			attack_effect_spawn_point.position.y = item_position_flipper
			projectile_spawn_point.position.x = -held_item_data.muzzle_flash_offset * 1.5
			attack_effect_spawn_point.position.x = held_item_data.muzzle_flash_offset
			projectile_spawn_point.rotation = held_item.rotation
			
		elif(held_item_data.has_method("swing")):
			if held_item_data.is_attacking:
				SPEED_MULTIPLER = 0.0
			else:
				SPEED_MULTIPLER = lerp(SPEED_MULTIPLER, 1.0, lerp_strength)
			#print(held_item_data.current_swing_time)
			handle_swing_plane()
			ranged_ray.enabled = false
			melee_hit_area.monitoring = true
			melee_hit_area.position = Vector2(held_item_data.effective_range * 0.25, held_item_data.effective_range * 0.475 * item_position_flipper)
			swing_size = (0.3 * item_rotation_flipper) * PI  
			held_item.offset = Vector2(0, held_item_data.handle_offset) * item_position_flipper
			#swing(0.01, held_item)
			#swing(0.01, hold_point)
			local_item_rot = rad_to_deg((aim_point.position).angle()) - (held_item_data.rotation_offset * item_rotation_flipper)
			local_item_pos = get_point_on_radius(position, aim_point.global_position, 
				(held_item_data.item_offset * item_position_flipper) * PI, held_item_data.hold_distance)
			local_hold_point = get_point_on_radius(position, aim_point.global_position, 
				(held_item_data.hold_point_offset * clamp(abs(aim_point.position.normalized().x), 0.1, 1) * item_position_flipper) * PI,
		 			held_item_data.hold_distance * 2)
			#local_hold_point = back_swing.position if held_item_data.swing_forward else forward_swing.position
			#local_item_pos = back_swing.position if held_item_data.swing_forward else forward_swing.position

	else:
		local_item_pos = (aim_point.position.normalized() * held_item_data.hold_distance)
		held_item.rotation = 0
		held_item.flip_v = false
		ranged_ray.enabled = false
		melee_hit_area.monitoring = false

	#held_item.rotation_degrees = local_item_rot
	held_item.rotation = lerp_angle(held_item.rotation, deg_to_rad(local_item_rot), lerp_strength)
	#held_item.position = local_item_pos
	held_item.position =  lerp(held_item.position, local_item_pos, lerp_strength * 3)
	#hold_point.position = local_hold_point
	hold_point.position = lerp(hold_point.position, local_hold_point, lerp_strength * 3)
	


func handle_aim_point(delta, lerp_strength):
	if targets_in_range:
		aim_point.global_position = lerp(aim_point.global_position,
			targets_in_range[locked_target_index].global_position - velocity * held_item_weight * 0.065, 
			lerp_strength * pow(0.5,2))
	else:
		targets_in_range.clear()
		if held_item_data.has_method("attack"):
			if held_item_data.has_method("shoot"):
				if held_item_data.is_reloading:
					lerp_strength = lerp_strength * 0.01
				if held_item_data.is_attacking:
					lerp_strength = lerp_strength * (held_item_data.recoil_strength.x) * 0.4
				if held_item.position.distance_to(lookDirection) < held_item_data.effective_range:
					if held_item.position.distance_to(lookDirection) < 40:
						aim_point.position = lerp(aim_point.position, lookDirection.normalized() * 40, lerp_strength * 0.75)
					else:
						aim_point.position = lerp(aim_point.position, lookDirection.normalized() *  held_item.position.distance_to(lookDirection), lerp_strength)
				else:
					aim_point.position = lerp(aim_point.position, lookDirection.normalized() * held_item_data.effective_range, lerp_strength * 0.35)
					
			elif held_item_data.has_method("swing"):
				if held_item_data.is_attacking:
					lerp_strength = lerp_strength * 0
				aim_point.position = lerp(aim_point.position, lookDirection.normalized() * held_item_data.effective_range * 0.7, lerp_strength)
		else:
			aim_point.position = lerp(aim_point.position, lookDirection.normalized() * 20, lerp_strength)
		

func handle_lock_on(delta, lerp_strength):
	if held_item_data.has_method("attack"):
		collision_shape_2d.shape.radius = held_item_data.effective_range
	else:
		collision_shape_2d.shape.radius = 20

	if can_lock_on and !hands_empty:
		lock_on_zone.monitoring = true
		aim_point.modulate = lerp(aim_point.modulate, Color(1,1,0,0.75), delta * 10)
	else:
		lock_on_zone.monitoring = false
		aim_point.modulate = lerp(aim_point.modulate, Color(1,1,1,0.75), delta * 10)

	if targets_in_range:
		print(aim_point.global_position.distance_to(targets_in_range[0].global_position))
		for target in targets_in_range:
			if targets_in_range.find(target) == locked_target_index:
				target.indicator.modulate = lerp(target.indicator.modulate, Color(1,1,0,0.75), delta * 10)
			else:
				target.indicator.modulate = lerp(target.indicator.modulate, Color(1,1,1,0.75), delta * 10)

func handle_swing_plane():
	swing_start.position = get_point_on_radius(position, aim_point.global_position, 
		(swing_size * 0.7), held_item_data.hold_distance * 0.85)
	swing_peak.position = get_point_on_radius(position, aim_point.global_position,  
		0.0 * item_rotation_flipper, held_item_data.hold_distance * 1.35)
	swing_end.position = get_point_on_radius(position, aim_point.global_position, 
		(-swing_size * 0.75), held_item_data.hold_distance * 0.85)
		
	hand_swing_start.position = get_point_on_radius(position, aim_point.global_position, 
		(swing_size), held_item_data.hold_distance * 2)
	hand_swing_peak.position = get_point_on_radius(position, aim_point.global_position,  
		0.0, held_item_data.hold_distance * 2.8)
	hand_swing_end.position = get_point_on_radius(position, aim_point.global_position, 
		(-swing_size * 0.9), held_item_data.hold_distance * 2)
		

func get_point_on_radius(center: Vector2, direction: Vector2, rotation_offset: float, radius):
	var radian: float = (center).angle_to_point(direction) - rotation_offset
	return Vector2(radius * cos(radian), radius * sin(radian))
	
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
		area.get_parent().indicator.modulate.a = lerp(area.get_parent().indicator.modulate.a, 0.75, lerp_strength)
		targets_in_range.push_back(area.get_parent())

func _on_lock_on_zone_area_exited(area):
	area.get_parent().indicator.modulate.a = lerp(area.get_parent().indicator.modulate.a, -3.5, lerp_strength)
	targets_in_range.pop_at(targets_in_range.find(area.get_parent()))
	if targets_in_range.size() < 2:
		locked_target_index = 0



