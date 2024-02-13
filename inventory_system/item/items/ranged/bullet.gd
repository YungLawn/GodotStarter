extends Area2D

class_name bullet

@onready var sprite_2d = $Sprite2D

var speed: int
var direction: Vector2
var damage: int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += direction * delta * (speed * 100)
	
func area_entered(body):
	print("hit")
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	#pass
	#print("gone")
	queue_free()


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("hit")
	queue_free()
