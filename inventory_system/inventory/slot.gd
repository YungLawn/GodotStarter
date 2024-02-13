extends PanelContainer

signal slot_clicked(index: int, button: int)

@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantity_label = $quantity_label
@onready var number_label = $number_label

func set_slot_data(slotdata: SlotData) -> void:
	var item_data = slotdata.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slotdata.quantity > 1: 
		quantity_label.text = "x%s" % slotdata.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)

