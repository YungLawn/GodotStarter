extends CharacterBody2D

signal toggle_inventory()

var rng = RandomNumberGenerator.new()
const SMOKE = preload("res://assets/icons/smoke.tscn")

@onready var bullet = preload("res://inventory_system/item/items/ranged/bullet.tscn")
@onready var interact_ray = $Camera2D/interact_ray
@onready var health_label = $HealthLabel
@onready var label = $Label
@onready var hot_bar = $"../UI/HotBar"
@onready var held_item = $BaseSprite/held_item
#@onready var effect = $BaseSprite/effect
@export var inventorydata: InventoryData
@export var equip_inventorydata: InventoryDataEquip
@onready var ammo_count = $ammo_count
#@onready var muzzle_flash = $muzzle_flash
@onready var projectile_spawn_point = $projectile_spawn_point

var is_pressed: bool
var can_press: bool = true

var health: int = 5
var hands_empty: bool = true
var selected_item_index: int = 1
var hold_distance_mult: float
#var ranged_recoil: Vector2

var held_item_data: ItemData

@export var SPEED = 0
@export var SPRINTMULTIPLIER = 1.5
var isSprinting = false
@onready var direction = Vector2(0,0)
@onready var lookDirection = Vector2(0,0)

func _ready():
	#health_label.text = str(health)
	PlayerManager.player = self
	#pass
	
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
	var random_number = rng.randf_range(-1.0, 1.0)
	var tween = create_tween()
	tween.tween_property(held_item, "rotation", held_item.rotation + (random_number * 1.5), 0.15).set_ease(Tween.EASE_OUT)
	health += heal_value
	#health_label.text = str(health)
	#print(health)
	
func weapon_fired():
	var smoke = SMOKE.instantiate()
	get_tree().root.add_child(smoke)
	smoke.global_position = projectile_spawn_point.global_position
	smoke.rotation = projectile_spawn_point.rotation
	smoke.amount = (held_item_data.recoil_strength * (held_item_data.muzzle_velocity * 0.5)) * 0.01
	smoke.process_material.scale_max = (held_item_data.recoil_strength * (held_item_data.muzzle_velocity * 0.5)) * 0.003
	smoke.process_material.initial_velocity_max = (held_item_data.recoil_strength * (held_item_data.muzzle_velocity * 0.5)) * 0.125
	smoke.emitting = true
	
func _physics_process(delta):
	velocity = direction.normalized() * (SPEED * SPRINTMULTIPLIER if isSprinting else SPEED)
	move_and_slide()
	
func _process(delta):
	toggleSprint()
	
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	lookDirection = get_local_mouse_position()

	if !hands_empty: handle_held_item(lookDirection)
	if held_item_data:
		$BaseSprite.animate(direction, lookDirection, hands_empty, held_item_data.offset)
		
	if held_item_data:
		held_item.position = ((lookDirection.normalized() * hold_distance_mult) - held_item_data.offset)
		if(held_item_data.has_method("shoot")):	
			projectile_spawn_point.position = ((lookDirection.normalized() * (hold_distance_mult * held_item_data.muzzle_flash_offset)) - (held_item_data.offset)) 
			projectile_spawn_point.rotation = held_item.rotation
			
func handle_held_item(lookDirection: Vector2):
	if held_item_data.rotatable:
		hold_distance_mult = 11.5
	else:
		hold_distance_mult = 9

	if lookDirection.normalized().y < 0:
		held_item.z_index = 0
	else: held_item.z_index = 1
	
	if lookDirection.normalized().x < 0 and held_item_data.rotatable:
		held_item.flip_v = true
	else:
		held_item.flip_v = false
		
	if(held_item_data.rotatable):
		held_item.rotation_degrees = rad_to_deg(get_angle_to(get_global_mouse_position() + (held_item_data.offset)))
	else:
		held_item.rotation = 0
		
	label.text = str(held_item.position.normalized())

func toggleSprint():
	if Input.is_action_just_pressed("sprint") and isSprinting == false:
		isSprinting = true
	elif Input.is_action_just_pressed("sprint") and isSprinting == true:
		isSprinting = false
	if(direction.x == 0 and direction.y == 0):
		isSprinting = false

func _on_hot_bar_set_selected_slot(index):
	selected_item_index = index
	if inventorydata.slot_datas[index]:
		held_item_data = inventorydata.slot_datas[index].item_data
		hands_empty = false
		held_item.texture = held_item_data.texture
	else:
		hands_empty = true
		held_item.texture = null
