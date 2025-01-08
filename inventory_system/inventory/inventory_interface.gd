extends Control

signal drop_slot_data(slot_data: SlotData)
signal force_close

const SLOT_THEME = preload("res://inventory_system/inventory/slot_theme.tres")
const SLOT_THEME_SELECTED = preload("res://inventory_system/inventory/slot_theme_selected.tres")

var grabbed_slot_data: SlotData
var external_inventory_owner
var mouse_over: bool = false

@onready var player_inventory: PanelContainer = $player_inventory
@onready var grabbedslot: PanelContainer = $grabbedslot
@onready var external_inventory = $external_inventory
@onready var equip_inventory = $equip_inventory
@onready var hot_bar: PanelContainer = $"../HotBar"

func _ready():
	equip_inventory.item_grid.columns = 1
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("test1"):
		for slot in Global.player.equip_inventory_data.slot_datas:
			print(slot.item_data.name)
	#if event is InputEventMouseButton:
		#player_inventory.indicate_selected_slot()
		#hot_bar.indicate_selected_slot()

func _process(delta):
	hot_bar.indicate_selected_slot()
	player_inventory.indicate_selected_slot()

func _physics_process(delta: float) -> void:
	if grabbedslot.visible:
		grabbedslot.global_position = get_global_mouse_position() + Vector2(5,5)
		
	if external_inventory_owner \
			and not external_inventory_owner.material.get_shader_parameter("is_outlined"):
		force_close.emit()
	
func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)
	
func set_equip_inventory_data(inventory_data: InventoryData) -> void:
	print("set_equip_initial")
	inventory_data.inventory_interact.connect(on_inventory_interact)
	equip_inventory.set_inventory_data(inventory_data)

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
	
func on_inventory_interact(inventory_data: InventoryData,
	 index: int, button: int) -> void:
	
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			if !inventory_data.slot_datas[index].item_data.has_method("attack"):
				inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
			
	update_grabbed_slot()
	
func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbedslot.show()
		grabbedslot.set_slot_data(grabbed_slot_data)
	else:
		grabbedslot.hide()
		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left click") \
		and grabbed_slot_data \
		and !mouse_over:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		#print("Drop")
		
		update_grabbed_slot()
	
func _on_mouse_entered():
	mouse_over = false;

func _on_mouse_exited():
	mouse_over = true;

func _on_visibility_changed():
	if !visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()

func _on_external_inventory_mouse_entered():
	mouse_over = true;

func _on_external_inventory_mouse_exited():
	mouse_over = false;
