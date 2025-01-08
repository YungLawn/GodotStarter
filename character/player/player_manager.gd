extends Node2D

signal hot_bar_use(index: int)
signal toggle_inventory()

@onready var label: Label = %Label
@onready var character: CharacterBody2D = $character
var selected_item_index: int
var inventory_open: bool

func _ready():
	character.ranged_item.state_unhandled_input.connect(_on_ranged_item_state_unhandled_input)
	character.held_item_state.state_unhandled_input.connect(_on_held_item_state_unhandled_input)
	#hot_bar_use.connect(character.inventory_data.use_slot_data)
	await get_tree().create_timer(0.5).timeout
	selected_item_index = character.inventory_data.slot_datas.size() - 9
	character.set_selected_item(selected_item_index)
	
func _on_held_item_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left click"):
		character.held_item_data.use(self)

func _physics_process(delta: float) -> void:
	#if character.held_item_data:
		#label.text = str(character.held_item_data.can_attack)
	character.direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	character.look_direction = (Crosshair.global_position - character.pivot_point.global_position).normalized() * clamp(character.pivot_point.global_position.distance_to(Crosshair.global_position), 20, 1000)

func _on_ranged_item_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reload"):
		character.held_item_data.reload(character, character.item_position_flipper)
		
func _on_hot_bar_set_selected_slot(index):
	selected_item_index = index
	character.set_selected_item(index)
