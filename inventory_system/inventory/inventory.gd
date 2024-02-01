extends PanelContainer

const slot = preload("res://inventory_system/inventory/slot.tscn")

@onready var item_grid = $MarginContainer/item_grid

func set_inventory_data(inventory_data: InventoryData) -> void:
	#print(inventory_data)
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)
	
func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)
	populate_item_grid(inventory_data)

func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in item_grid.get_children():
		child.queue_free()
		

	for index in inventory_data.slot_datas.size():
		var slot_data = inventory_data.slot_datas[index]
		var slot = slot.instantiate()
		item_grid.add_child(slot)
		
		if index > inventory_data.slot_datas.size() - 10 and inventory_data.slot_datas.size() > 18:	
			slot.number_label.text = str(index - (inventory_data.slot_datas.size() - 10))
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
		
	#for slot_data in inventory_data.slot_datas:
		#var slot = slot.instantiate()
		#item_grid.add_child(slot)
		#
		#slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		#
		#if slot_data:
			#slot.set_slot_data(slot_data)



