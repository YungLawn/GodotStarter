extends RayCast2D

@onready var player = $"../.."

func _process(delta):
	#direction = Vector2(cos(position.angle_to_point(player.position)), sin(position.angle_to_point(player.position))).normalized()
	#var mousepos = get_viewport().get_mouse_position()
	var mousepos = get_local_mouse_position() + Vector2(0, 10)
	target_position = Vector2(cos(position.angle_to_point(mousepos)), 
		sin(position.angle_to_point(mousepos))).normalized() * 10
	#print(Vector2(cos(position.angle_to_point(mousepos)), sin(position.angle_to_point(mousepos))).normalized())
	#print(str(mousepos.normalized()))
