extends Node2D

const PickUp = preload("res://assets/pickups/pick_up.tscn")

@onready var player = $player
@onready var inventory_interface = $UI/inventory_interface
@onready var hot_bar = $UI/HotBar

# Called when the node enters the scene tree for the first time.
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
	
	if inventory_interface.visible:
		hot_bar.hide()
	else:
		hot_bar.show()	
	#if inventory_interface.visible:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#else:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:	
		inventory_interface.clear_external_inventory()

func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.position + Vector2(10,-10)
	add_child(pick_up)
