extends Node2D

@export var slot_data: SlotData
@onready var sprite_2d = $Sprite2D
@onready var area_2d: Area2D = $Area2D

var counter: float
var locked_on: bool = false
var target_pos: Vector2
var player

func _ready() -> void:
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
		position = lerp(position, player.pivot_point.global_position, delta * 10)
		scale = lerp(scale, Vector2.ZERO, delta * 10)
		if global_position.distance_to(player.pivot_point.global_position) < 3.0 and player.inventorydata.pick_up_slot_data(slot_data):
			queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body
		locked_on = true
