extends Line2D

var queue: Array
var pos: Vector2
var is_trailing: bool
@export var MAX_LENGTH: int = 10
#var point_velocity: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = Vector2(0,0)
	global_rotation = 0
	
	queue.push_front(get_parent().global_position)
	
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
		
	clear_points()
	
	for point in queue:
		add_point(point)
	
