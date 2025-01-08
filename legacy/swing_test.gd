extends Node2D

@onready var start = $start
@onready var peak = $peak
@onready var end = $end
@onready var item = $item
@onready var label = $Label

@onready var test: float = 0.0

func _unhandled_input(event):
	if Input.is_action_pressed("left click"):
		swing()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = str(test)

func swing():
	var tween = create_tween()
	
	if test == 0.0:
		tween.tween_method(tween_number, test, 1.0, 1)
	elif test == 1.0:
		tween.tween_method(tween_number, test, 0.0, 1)
	
func tween_number(value: float):
	test = value
