extends Control

signal drop_slot_data(slot_data: SlotData)

var grabbed_slot_data: SlotData
var external_inventory_owner

@onready var player_inventory: PanelContainer = $player_inventory
@onready var grabbedslot: PanelContainer = $grabbedslot
@onready var external_inventory = $external_inventory

func _physics_process(delta: float) -> void:
	if grabbedslot.visible:
		grabbedslot.global_position = get_global_mouse_position() + Vector2(1,1)
	
func set_player_inventory_data(inventorydata: InventoryData) -> void:
	inventorydata.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventorydata)

func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()

func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null
	
func on_inventory_interact(inventorydata: InventoryData,
		 index: int, button: int) -> void:
	
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventorydata.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventorydata.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			pass
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventorydata.drop_single_slot_data(grabbed_slot_data, index)
			
	update_grabbed_slot()
	
func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbedslot.show()
		grabbedslot.set_slot_data(grabbed_slot_data)
	else:
		grabbedslot.hide()
		
func _input(event: InputEvent) -> void:
	#print("gui: ", event)
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data:
				print("!!")
				#
		#match event.button_index:
			#MOUSE_BUTTON_LEFT:
				#drop_slot_data.emit(grabbed_slot_data)
				#grabbed_slot_data = null
				#print("Drop")
	#update_grabbed_slot()
	
func _on_mouse_entered():
	print("over")


func _on_mouse_exited():
	print("not over")


func _on_gui_input(event):
	print("!!")

