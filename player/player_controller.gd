extends CharacterBody2D

signal toggle_inventory()

var rng = RandomNumberGenerator.new()
const SMOKE = preload("res://assets/icons/smoke.tscn")

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
@onready var attack_ray = $BaseSprite/held_item/attack_ray
@onready var aim_point = $aim_point

@onready var back_swing = $BaseSprite/back_swing
@onready var forward_swing = $BaseSprite/forward_swing
@onready var peak_swing = $BaseSprite/peak_swing


@export var SPEED: float = 50

var is_pressed: bool
var can_press: bool = true

var health: int = 5
var hands_empty: bool = true
var held_item_data: ItemData
var held_item_weight: float

var direction: Vector2 = Vector2(0,0)
var lookDirection: Vector2 = Vector2(0,0)

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
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("reload"):
		if held_item_data.has_method("reload"):
			held_item_data.reload(self)

func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
		
func heal(heal_value: int) -> void:
	var random_number = rng.randf_range(0.5, 1)
	health += heal_value
	if held_item_data.has_method("heal"):
		var tween = create_tween()
		tween.tween_property(held_item, "rotation", held_item.rotation + (random_number * 1.5), 0.15).set_ease(Tween.EASE_OUT)
	
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
	
func item_swung():
	print("swing")

func _physics_process(delta):
	velocity = direction.normalized() * SPEED 
	move_and_slide()
	
func _process(delta):
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	lookDirection = get_local_mouse_position()
	
	base_sprite.animate(direction, lookDirection)

	if held_item_data:
		handle_held_item()

func handle_held_item():
	var rotation_offset: float
	
	base_sprite.handle_hands(held_item_data.offset + held_item_data.hand_offset, hands_empty, lookDirection)
	held_item.position = (lookDirection.normalized() * held_item_data.hold_distance) - held_item_data.offset

	aim_point.position = ((lookDirection + (held_item_data.offset * 2)).normalized() * (held_item_data.hold_distance * 10))

	#print(held_item.position)
	#print(rad_to_deg(lookDirection.angle()))
	#print(rad_to_deg(lookDirection.angle()) + 30)
	
	if lookDirection.normalized().y < 0:
		held_item.z_index = 0
	else: held_item.z_index = 1
	
	
	if lookDirection.normalized().x < 0 and held_item_data.rotatable:
		swing_size = -0.3 * PI
		held_item.flip_v = true
		held_item.offset.y = held_item_data.offset.y * 0.5
		projectile_spawn_point.position.y = held_item_data.offset.y * 0.75
		attack_effect_spawn_point.position.y = held_item_data.offset.y * 0.75
		attack_ray.position.y = held_item_data.offset.y * 0.5
	else:
		swing_size = 0.3 * PI
		held_item.flip_v = false
		held_item.offset.y = -held_item_data.offset.y * 0.5
		projectile_spawn_point.position.y = -held_item_data.offset.y * 0.75
		attack_effect_spawn_point.position.y = -held_item_data.offset.y * 0.75
		attack_ray.position.y = -held_item_data.offset.y * 0.5
		
	if(held_item_data.rotatable):
		attack_ray.enabled = true
		
		if lookDirection.normalized().x < 0:
			rotation_offset = held_item_data.rotation_offset
		else:
			rotation_offset = -held_item_data.rotation_offset
		var item_pos_rad = rad_to_deg((aim_point.position).angle())
		held_item.rotation_degrees = item_pos_rad + rotation_offset

	else:
		attack_ray.enabled = false
		held_item.rotation = 0

	if(held_item_data.has_method("shoot")):	
		#Input.set_custom_mouse_cursor(held_item_data.crosshair_sprite)
		attack_ray.target_position.x = held_item_data.muzzle_velocity * 0.01
		projectile_spawn_point.position.x = -held_item_data.muzzle_flash_offset * 1.5
		attack_effect_spawn_point.position.x = held_item_data.muzzle_flash_offset
		projectile_spawn_point.rotation = held_item.rotation
	elif(held_item_data.has_method("swing")):	
		var tmp = deg_to_rad(held_item.rotation_degrees - rotation_offset) - swing_size
		var tmp2 = deg_to_rad(held_item.rotation_degrees - rotation_offset) + swing_size
		var tmp3 = deg_to_rad(held_item.rotation_degrees - rotation_offset)
		var radius_back = held_item_data.hold_distance * 1.1
		var radius_front = held_item_data.hold_distance * 1.1
		var radius_peak = held_item_data.hold_distance * 1.2
		back_swing.position = Vector2(radius_back * cos(tmp), radius_back * sin(tmp)) - held_item_data.offset
		forward_swing.position = Vector2(radius_front * cos(tmp2), radius_front * sin(tmp2)) - held_item_data.offset
		peak_swing.position = Vector2(radius_peak * cos(tmp3), radius_peak * sin(tmp3)) - held_item_data.offset

func _on_hot_bar_set_selected_slot(index):
	if inventorydata.slot_datas[index]:
		held_item_data = inventorydata.slot_datas[index].item_data
		hands_empty = false
		held_item.texture = held_item_data.texture
		held_item_weight = held_item_data.weight
	else:
		hands_empty = true
		held_item.texture = null
