extends PanelContainer

signal hot_bar_use(index: int)

const SLOT_THEME = preload("res://inventory_system/inventory/slot_theme.tres")
const SLOT_THEME_SELECTED = preload("res://inventory_system/inventory/slot_theme_selected.tres")

const slot = preload("res://inventory_system/inventory/slot.tscn")
@onready var h_box_container = $MarginContainer/HBoxContainer
@onready var sprite_2d = $Sprite2D

var selected_slot: float

#func _input(event):
	#if Input.is_action_just_pressed("test1"):
		#number_label.text = "1"

func _process(delta):
	var tex = h_box_container.get_child(0).get_child(0).get_child(0).texture
	indicate_selected_slot()
	sprite_2d.texture = tex
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		hot_bar_use.emit(selected_slot + 18)
	
func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return
		
	if range(KEY_1, KEY_A).has(event.keycode):
		selected_slot = event.keycode - KEY_1
		hot_bar_use.emit(selected_slot + 18)

func indicate_selected_slot():	
	for slot_index in h_box_container.get_children().size():
		var slot = h_box_container.get_child(slot_index)
		if slot_index == selected_slot:
			slot.add_theme_stylebox_override ("panel", SLOT_THEME_SELECTED)
		else:
			slot.add_theme_stylebox_override ("panel", SLOT_THEME)
	
	if Input.is_action_just_pressed("scroll_wheel_up"):
		if selected_slot >= h_box_container.get_children().size():
			selected_slot = 0
		else:
			selected_slot += 1
	elif Input.is_action_just_pressed("scroll_wheel_down"):
		if selected_slot <= 0:
			selected_slot = 9
		else:
			selected_slot -= 1


func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(inventory_data)
	hot_bar_use.connect(inventory_data.use_slot_data)

func populate_hot_bar(inventory_data: InventoryData) -> void:
	for child in h_box_container.get_children():
		child.queue_free()
	
	var number: int = 1
	for slot_data in inventory_data.slot_datas.slice(18,27):
		var slot = slot.instantiate()
		h_box_container.add_child(slot)
		slot.number_label.text = str(number)
		number+=1
		
		if slot_data:
			slot.set_slot_data(slot_data)
			#print(slot_data.quantity)
			

