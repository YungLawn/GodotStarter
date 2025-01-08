extends Node2D

@onready var character: CharacterBody2D = $".."

func _ready():
	await get_tree().create_timer(0.5).timeout
	character.set_selected_item(character.inventory_data.slot_datas.size() - 9)

func _unhandled_input(event: InputEvent) -> void:
	character.is_pressed = Input.is_action_pressed("left_click")

func _physics_process(delta: float) -> void:
	character.direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	character.look_direction = (Crosshair.global_position - character.pivot_point.global_position).normalized() * clamp(character.pivot_point.global_position.distance_to(Crosshair.global_position), 20, 1000)

func _on_ranged_item_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reload"):
		character.held_item_data.reload(character, character.item_position_flipper)
		
func _on_hot_bar_set_selected_slot(index):
	character.set_selected_item(index)
