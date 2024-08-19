extends VBoxContainer

@onready var seed = $seed
@onready var width = $width
@onready var height = $height
@onready var in_game_menu = $"../../.."
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_clear_pressed():
	in_game_menu.world.clear()
