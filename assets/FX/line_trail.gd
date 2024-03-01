extends Line2D

var queue: Array
var pos: Vector2
@export var MAX_LENGTH: int = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue.push_front(pos)
	
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
		
	clear_points()
	
	for point in queue:
		add_point(point)
	
