extends InventoryData
class_name InventoryDataEquip

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	#print(grabbed_slot_data.item_data.type)
	#print(PlayerManager.player.equip_inventorydata.slot_datas)
	var types: Array
	for slot in PlayerManager.player.equip_inventorydata.slot_datas:
		if slot:
			types.push_front(slot.item_data.type)
			#print(slot.item_data.name + ": " + slot.item_data.type)
		#else: print("no item in slot. grabbed item is: " + grabbed_slot_data.item_data.name + ": " + grabbed_slot_data.item_data.type)
	
	#print(types)
	if not grabbed_slot_data.item_data is itemDataEquip or grabbed_slot_data.item_data.type in types:
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, index)
	
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	print(grabbed_slot_data.item_data.name)
	
	if not grabbed_slot_data.item_data is itemDataEquip:
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, index)
