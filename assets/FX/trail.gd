extends Line2D
class_name Trail
 
var queue : Array
@export var MAX_LENGTH : int

func _process(_delta):
	
	add_point(global_position)
	print(points)
	#queue.push_front(pos)
 #
	#if queue.size() > MAX_LENGTH:
		#queue.pop_back()
 #
	#clear_points()
 #
 #
	#for point in queue:
		#add_point(point)
