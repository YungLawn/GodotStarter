extends Node2D

signal hot_bar_use(index: int)

@onready var character: CharacterBody2D = $character
@onready var detection_area: Area2D = %detection_area
@onready var label: Label = %Label3
@onready var behavior_state_chart: StateChart = %behavior_state_chart

var target_in_range: bool
var target: Node2D = null
var selected_item_index: int = 0
var enemy_time_in_range: float = 0.0

var inventory_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#character.localize_inventory()
	await get_tree().create_timer(0.5).timeout
	character.set_selected_item(character.inventory_data.slot_datas.size() - 8)
	character.look_direction = Vector2(0,100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemy_time_in_range > 1.0:
		behavior_state_chart.send_event("threat_detected")
	else:
		behavior_state_chart.send_event("threat_over")
	#if character.held_item_data:
		#label.text = str(character.held_item_data.can_attack)

func _on_detection_area_area_entered(area: Area2D) -> void:
	behavior_state_chart.set_expression_property("time_in_range", enemy_time_in_range)
	
	if area.get_parent().get_parent().is_in_group("player"):
		target = area.get_parent()
		behavior_state_chart.send_event("enemy_entered")
	target_in_range = true

func _on_detection_area_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent().is_in_group("player"):
		behavior_state_chart.send_event("enemy_exited")
	target_in_range = false

func _on_alert_state_state_physics_processing(delta: float) -> void:
	enemy_time_in_range += delta
	character.look_direction = lerp(character.look_direction,
		(target.global_position - character.global_position).normalized() * clamp(character.global_position.distance_to(Crosshair.global_position), 20, 1000),
		character.lerp_strength * 0.25)

func _on_alert_state_state_exited() -> void:
	enemy_time_in_range = 0.0
	target = null

func _on_idle_state_state_entered() -> void:
	await get_tree().create_timer(3).timeout
	if character.held_item_data:
		if character.held_item_data.has_method("shoot"):
			if character.held_item_data.current_capacity < character.held_item_data.max_capacity:
				character.held_item_data.reload(character, character.item_position_flipper)

func _on_attacking_state_processing(delta: float) -> void:
	if character.held_item_data.can_attack:
		await get_tree().create_timer(randf_range(0.1,1)).timeout
		character.held_item_data.use(self)
	if character.held_item_data.has_method("shoot"):
		if character.held_item_data.current_capacity == 0:
			character.held_item_data.reload(character, character.item_position_flipper)
