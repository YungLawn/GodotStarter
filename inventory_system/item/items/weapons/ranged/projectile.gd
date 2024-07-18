extends Node2D

class_name projectile

@onready var rng = RandomNumberGenerator.new()

@onready var traveling_ray = $traveling_ray
@onready var sprite = $sprite

var velocity: int
var direction: Vector2
var damage: int
var texture: AtlasTexture
var accuracy: float
var accuracy_modifier

func _ready():
	sprite.visible = false

func _process(delta):
	var calc_velo: float = velocity * delta * 0.6
	move(calc_velo, traveling_ray)
	
func hit(target, damage, direction):
	#print(target.name)
	if target.get_parent().is_in_group("damageable"):
		target.get_parent().take_damage(damage, direction)
	elif target.is_in_group("damageable"):
		target.take_damage(damage, direction)
	queue_free()

func move(velo: float, ray: RayCast2D):
	global_position += (direction  * velo)
	ray.target_position.x = velo * 2
	#ray.position.x = -velo * 1.5
	await get_tree().create_timer(0.01).timeout
	sprite.visible = true
	if traveling_ray.is_colliding():
		hit(traveling_ray.get_collider(), damage, direction)


func _on_visible_on_screen_notifier_2d_screen_exited():
	#print("gone")
	await get_tree().create_timer(5).timeout
	queue_free()
