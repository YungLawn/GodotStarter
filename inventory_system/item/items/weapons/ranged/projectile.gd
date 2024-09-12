extends Node2D

class_name projectile

@onready var rng = RandomNumberGenerator.new()
@onready var hit_detection: RayCast2D = %hit_detection

var velocity: int
var direction: Vector2
var damage: int
var texture: AtlasTexture
var accuracy: float
var accuracy_modifier

#func _ready():
	#visible = false

func _process(delta):
	var calc_velo: float = velocity * delta * 0.6
	move(calc_velo)
	
func hit(target, damage, direction):
	#print(target.name)
	if target.get_parent().is_in_group("damageable"):
		target.get_parent().take_damage(damage, direction)
	elif target.is_in_group("damageable"):
		target.take_damage(damage, direction)
	queue_free()

func move(velo: float):
	global_position += (direction  * velo)
	hit_detection.target_position.x = velo * 2
	hit_detection.position.x = -velo * 1.5
	await get_tree().create_timer(abs(velocity - 6000) * 0.0000125).timeout
	visible = true
	if hit_detection.is_colliding():
		hit(hit_detection.get_collider(), damage, direction)

func _on_visible_on_screen_notifier_2d_screen_exited():
	#print("gone")
	queue_free()
