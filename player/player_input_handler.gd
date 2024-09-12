extends Node2D

@onready var player: CharacterBody2D = $".."

func _ready():
	await get_tree().create_timer(0.5).timeout
	player.set_selected_item(player.inventorydata.slot_datas.size() - 9)

func _unhandled_input(event: InputEvent) -> void:
	player.is_pressed = Input.is_action_pressed("left_click")

func _physics_process(delta: float) -> void:
	player.direction = Input.get_vector("move_west", "move_east", "move_north", "move_south")
	player.look_direction = (Crosshair.global_position - player.pivot_point.global_position).normalized() * clamp(player.pivot_point.global_position.distance_to(Crosshair.global_position), 20, 1000)

func _on_ranged_item_state_unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reload"):
		player.held_item_data.reload(player, player.item_position_flipper)
		
func _on_hot_bar_set_selected_slot(index):
	player.set_selected_item(index)
