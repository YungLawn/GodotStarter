extends PanelContainer

const slot = preload("res://inventory_system/inventory/slot.tscn")

const SLOT_THEME = preload("res://inventory_system/inventory/slot_theme.tres")
const SLOT_THEME_SELECTED = preload("res://inventory_system/inventory/slot_theme_selected.tres")

@onready var item_grid = $MarginContainer/item_grid
@onready var hot_bar: PanelContainer = $"../../HotBar"

func set_inventory_data(inventory_data: InventoryData) -> void:
	#print(inventory_data)
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)
	
func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)
	populate_item_grid(inventory_data)

func populate_item_grid(inventory_data: InventoryData) -> void:
	if inventory_data == Global.player.character.inventory_data:
		print("populate_player_inv")
	else:
		print("populate_external_inv")
	for child in item_grid.get_children():
		child.queue_free()

	#if inventory_data is inventory_dataEquip:
		#for slot in inventory_data.slot_datas:
			#print(slot)

	for index in inventory_data.slot_datas.size():
		var slot_data = inventory_data.slot_datas[index]
		var slot = slot.instantiate()
		item_grid.add_child(slot)
		
		if index > inventory_data.slot_datas.size() - 10 and inventory_data.slot_datas.size() > 18:	
			slot.number_label.text = str(index - (inventory_data.slot_datas.size() - 10))
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		#if slot_data:
			#if Global.player.character.local_inventory[index].item_data.name != slot_data.item_data.name:
				#print("local: " + Global.player.character.local_inventory[index].item_data.name + "|" + "global: " + slot_data.item_data.name)
				#slot.set_slot_data(Global.player.character.local_inventory[index])
			#else:
				#slot.set_slot_data(slot_data)
				
		if slot_data:
			slot.set_slot_data(slot_data)
			
		#Global.player.character.localize_inventory()

	#for slot_data in inventory_data.slot_datas:
		#var slot = slot.instantiate()
		#item_grid.add_child(slot)
		#
		#slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		#
		#if slot_data:
			#slot.set_slot_data(slot_data)
			
func indicate_selected_slot():
	var index = hot_bar.selected_slot
	var adjusted_index = index + item_grid.get_children().size() - 9
	#print(item_grid.get_children().size())
	for slot_index in item_grid.get_children().size():
		var slot = item_grid.get_child(slot_index)
		slot.selected = slot_index == adjusted_index
