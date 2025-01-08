extends Node2D

const PickUp = preload("res://inventory_system/pickups/pick_up.tscn")

@onready var player = $player
@onready var inventory_interface = $UI/inventory_interface
@onready var external_inventory: PanelContainer = $UI/inventory_interface/external_inventory
@onready var hot_bar = $UI/HotBar
@onready var label = $UI/Label
@onready var ammo_count = $UI/HBoxContainer/ammo_count
@onready var health_label = $UI/HBoxContainer/health_label
@onready var fps_counter = $UI/HBoxContainer/FPS_counter


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory_action"):
		#pass
		player.toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		player.character.interact()

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	fps_counter.text = "FPS: " + str(Engine.get_frames_per_second())
	health_label.text ="Health: " +  str(player.character.health)
	if player.character.held_item_data:
		if player.character.held_item_data.has_method("shoot"):
			ammo_count.text = str(player.character.held_item_data.current_capacity) + "/" + str(player.character.held_item_data.max_capacity)
		else: ammo_count.text = ""

func _ready():
	Global.player = player
	Global.external_inventory = external_inventory
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.character.inventory_data)
	inventory_interface.set_equip_inventory_data(player.character.equip_inventory_data)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	hot_bar.set_inventory_data(player.character.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	player.inventory_open = inventory_interface.visible
	
	if inventory_interface.visible:
		hot_bar.hide()
	else:
		hot_bar.show()	

	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:	
		inventory_interface.clear_external_inventory()

func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.position = player.character.pivot_point.global_position
	pick_up.target_pos = player.character.pivot_point.global_position + player.character.look_direction.normalized() * 30
	pick_up.slot_data = slot_data
	#pick_up.position = player.position + Vector2(20,-20)
	add_child(pick_up)
