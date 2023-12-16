@tool
extends TileMap

@export var MAP_SIZE: Vector2
const LAND_CAP = 0.2
var noise = FastNoiseLite.new()
@onready var player = $"../player"
@export var seed: int
@export var is_generating: bool
@export var is_clear: bool

func _ready():
	pass
	#generate_chunk(player.position, seed, MAP_SIZE)
	
func _process(delta):
		if Engine.is_editor_hint():
			if is_clear: 
				clear()
				is_clear = false
			if is_generating:
				clear()
				generate_chunk($"../player".position, seed, MAP_SIZE)
				is_generating = false

	
func _input(event):
	if(event.is_action_pressed("test1")):
		generate_chunk(player.position, seed, MAP_SIZE)
	if(event.is_action_pressed("test2")):
		pass
	
func generate_chunk(position, seed, size):
	var land = []
	noise.seed = seed
	var tile_pos = local_to_map(position)
	for x in size.x:
		for y in size.y:
			var current_pos = Vector2(tile_pos.x-MAP_SIZE.x/2 + x, tile_pos.y-MAP_SIZE.y/2 + y)
			var a = noise.get_noise_2d(current_pos.x, current_pos.y)
			if a <= LAND_CAP:
				land.append(Vector2(current_pos.x, current_pos.y))
				#set_cell(0, Vector2(tile_pos.x-MAP_SIZE.x/2 + x, tile_pos.y-MAP_SIZE.y/2 + y),0 , Vector2(1, 1), 0)
			elif a >= LAND_CAP:
				#water.append(Vector2(tile_pos.x-MAP_SIZE.x/2 + x, tile_pos.y-MAP_SIZE.y/2 + y))
				set_cell(0, Vector2(current_pos.x, current_pos.y),0 , Vector2(0, 5), 0)
	set_cells_terrain_connect(0, land, 0, 0)
	#set_cells_terrain_connect(0, water, 0, 1)

	

