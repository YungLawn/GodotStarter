extends CharacterBody2D

signal toggle_inventory()

@onready var interact_ray = $Camera2D/interact_ray
@onready var health_label = $HealthLabel
@onready var label = $Label
@onready var hot_bar = $"../UI/HotBar"
@onready var held_item = $held_item
@export var inventorydata: InventoryData
@export var equip_inventorydata: InventoryDataEquip


var health: int = 5
var hands_empty: bool = true

@export var SPEED = 0
@export var SPRINTMULTIPLIER = 1.5
var isSprinting = false
@onready var direction = Vector2(0,0)
@onready var lookDirection = Vector2(0,0)

func _ready():
	health_label.text = str(health)
	PlayerManager.player = self
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory_action"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()
		
func interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
		
func heal(heal_value: int) -> void:
	health += heal_value
	health_label.text = str(health)
	#print(health)

func _physics_process(delta):
	velocity = direction.normalized() * (SPEED * SPRINTMULTIPLIER if isSprinting else SPEED)
	move_and_slide()
	
func _process(delta):
	toggleSprint()
	
	direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	lookDirection = rad_to_deg(get_angle_to(get_global_mouse_position()))
	
	label.text = str(lookDirection)

	$BaseSprite.animate(direction, lookDirection, hands_empty)
	
func toggleSprint():
	if Input.is_action_just_pressed("sprint") and isSprinting == false:
		isSprinting = true
	elif Input.is_action_just_pressed("sprint") and isSprinting == true:
		isSprinting = false
	if(direction.x == 0 and direction.y == 0):
		isSprinting = false
	return isSprinting


func _on_hot_bar_set_selected_slot(index):
	#print(inventorydata.slot_datas[index])
	if inventorydata.slot_datas[index]:
		hands_empty = false
		held_item.texture = inventorydata.slot_datas[index].item_data.texture
	else:
		hands_empty = true
		held_item.texture = null
