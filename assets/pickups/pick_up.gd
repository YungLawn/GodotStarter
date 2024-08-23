extends Node2D

@export var slot_data: SlotData
@onready var sprite_2d = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var quantity: Label = %quantity

var counter: float
var locked_on: bool = false
var target_pos: Vector2
var player

func _ready() -> void:
	quantity.text = "x" + str(slot_data.quantity) if slot_data.quantity > 1 else ""
	var tween = create_tween()
	#tween.tween_property(self, "global_position", target_pos, 0.25).finished.connect(func(): area_2d.monitoring = true)
	if target_pos:
		tween.tween_property(self, "global_position", target_pos, 0.25).finished.connect(func(): area_2d.monitoring = true)
	else:  area_2d.monitoring = true
		
	sprite_2d.texture = slot_data.item_data.texture

func _physics_process(delta: float) -> void:
	counter += delta
	var movement: float = 0.025 * sin(counter * 3)
	position.y += movement
	if locked_on:
		position = lerp(position, player.interaction_zone.global_position, delta * 15)
		scale = lerp(scale, Vector2.ZERO, delta * 10)
		#if global_position.distance_to(player.interaction_zone.global_position) < 3.0 and player.inventorydata.pick_up_slot_data(slot_data):
		if global_position.distance_to(player.interaction_zone.global_position) < 3.0 \
			and player.inventorydata.pick_up_slot_data(slot_data):
			queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		player = area.get_parent()
		#print(player.inventorydata.slot_datas.has(null))
		if player.inventorydata.slot_datas.has(null):
			locked_on = true
