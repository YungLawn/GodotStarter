extends StaticBody2D

signal toggle_inventory(external_inventory_owner)
signal force_close

@export var inventory_data: InventoryData
@onready var sprite: Sprite2D = $sprite
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

var hovered: bool = false
var player_near: bool = false

func player_interact() -> void:
	#sprite.material.set_shader_parameter("is_outlined", true)
	toggle_inventory.emit(self)
	
func _physics_process(delta: float) -> void:
	if player_near and global_position.distance_to(Crosshair.global_position) < 10:
		material.set_shader_parameter("is_outlined", true)
	else:
		material.set_shader_parameter("is_outlined", false)
	
func take_damage(damage: float, direction: Vector2):
	var tween = create_tween().set_parallel(true)
	
	material.set_shader_parameter("is_hit", true)
	tween.tween_property(sprite, "rotation_degrees", rotation_degrees, 0.05).from(rotation_degrees + randf_range(-20, 20)).finished.connect(func(): 
				material.set_shader_parameter("is_hit", false)
				rotation_degrees = 0
				tween.kill()
				)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent().is_in_group("player"):
		player_near = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent().is_in_group("player"):
		player_near = false
