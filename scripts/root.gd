extends Node2D

const PickUp = preload("res://assets/pickups/pick_up.tscn")

@onready var player = $ik_player
@onready var inventory_interface = $UI/inventory_interface
@onready var hot_bar = $UI/HotBar
@onready var label = $UI/Label
@onready var ammo_count = $UI/HBoxContainer/ammo_count
@onready var health_label = $UI/HBoxContainer/health_label
@onready var fps_counter = $UI/HBoxContainer/FPS_counter

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	inventory_interface.indicate_selected_slot(hot_bar.selected_slot)
	hot_bar.indicate_selected_slot()
	fps_counter.text = "FPS: " + str(Engine.get_frames_per_second())
	health_label.text ="Health: " +  str(player.health)
	if player.held_item_data:
		if player.held_item_data.has_method("shoot"):
			ammo_count.text = str(player.held_item_data.current_capacity) + "/" + str(player.held_item_data.max_capacity)
		else: ammo_count.text = ""
			

func _ready():
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventorydata)
	inventory_interface.set_equip_inventory_data(player.equip_inventorydata)
	inventory_interface.force_close.connect(toggle_inventory_interface)
	hot_bar.set_inventory_data(player.inventorydata)
	
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
	pick_up.position = player.pivot_point.global_position
	pick_up.target_pos = player.pivot_point.global_position + player.look_direction.normalized() * 30
	pick_up.slot_data = slot_data
	#pick_up.position = player.position + Vector2(20,-20)
	add_child(pick_up)
