extends VBoxContainer

@onready var seed = $seed
@onready var width = $width
@onready var height = $height
@onready var in_game_menu = $"../../.."
@onready var player = in_game_menu.player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_generate_pressed():
	player = in_game_menu.player
	print(player)
	in_game_menu.world.clear()
	in_game_menu.world.generate_chunk(player.position, int(seed.text), Vector2(int(width.text),int(height.text)))


func _on_clear_pressed():
	in_game_menu.world.clear()
