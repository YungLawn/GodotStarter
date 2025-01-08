extends PanelContainer

signal hot_bar_use(index: int)
signal set_selected_slot(index: int)

const SLOT_THEME = preload("res://inventory_system/inventory/slot_theme.tres")
const SLOT_THEME_SELECTED = preload("res://inventory_system/inventory/slot_theme_selected.tres")

const slot = preload("res://inventory_system/inventory/slot.tscn")
@onready var h_box_container = $MarginContainer/HBoxContainer

var selected_slot: float = 0
var selected_item: ItemData

func _unhandled_input(event):
	if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		set_selected_slot.emit(selected_slot + Global.player.character.inventory_data.slot_datas.size() - 9)
	
	if Input.is_action_pressed("scroll_wheel_up"):
		if selected_slot >= h_box_container.get_children().size()-1:
			selected_slot = 0
		else:
			selected_slot += 1
	elif Input.is_action_pressed("scroll_wheel_down"):
		if selected_slot == 0:
			selected_slot = 8
		else:
			selected_slot -= 1

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return

	if range(KEY_1, KEY_A).has(event.keycode):
		if selected_slot == event.keycode - KEY_1:
			hot_bar_use.emit(selected_slot + Global.player.character.inventory_data.slot_datas.size() - 9)
		else:
			selected_slot = event.keycode - KEY_1
			set_selected_slot.emit(selected_slot + Global.player.character.inventory_data.slot_datas.size() - 9)

func indicate_selected_slot():	
	for slot_index in h_box_container.get_children().size():
		var slot = h_box_container.get_child(slot_index)
		slot.selected = slot_index == selected_slot

func set_inventory_data(inventory_data: InventoryData) -> void:
	#print("pop")
	inventory_data.inventory_updated.connect(populate_hot_bar)
	hot_bar_use.connect(inventory_data.use_slot_data)
	populate_hot_bar(inventory_data)
	
	#indicate_selected_slot()

func populate_hot_bar(inventory_data: InventoryData) -> void:
	#print("populate_hot_bar")
	for child in h_box_container.get_children():
		child.queue_free()
	
	var number: int = 1
	for slot_data in inventory_data.slot_datas.slice(inventory_data.slot_datas.size() - 9,inventory_data.slot_datas.size()):
		#print(slot_data.item_data.name)
		var slot = slot.instantiate()
		h_box_container.add_child(slot)
		slot.number_label.text = str(number)
		number+=1
		
		if slot_data:
			slot.set_slot_data(slot_data)
			#print(slot_data.quantity)
	set_selected_slot.connect(Global.player._on_hot_bar_set_selected_slot)
