extends TileMap

const MAP_SIZE = Vector2(50, 30)
const LAND_CAP = 0.1
var noise = FastNoiseLite.new()
var lastChunk = Vector2(0,0)
@onready var player = $"../player"

func _ready():
	noise.seed = 100 
	
func _process(delta):
	$"../player/Debug4".text = str(lastChunk.distance_to(player.position))
	if(lastChunk.distance_to(player.position) >= 1):
		lastChunk = player.position
		generate_chunk(player.position)
	
func _input(event):
	if(event.is_action_pressed("test1")):
		generate_chunk(player.position)
		
func generate_chunk(position):
	var tile_pos = local_to_map(position)
	var cells = []
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			var a = noise.get_noise_2d(tile_pos.x-MAP_SIZE.x/2 + x, tile_pos.y-MAP_SIZE.y/2 + y)
			if a < LAND_CAP:
				set_cell(0, Vector2(tile_pos.x-MAP_SIZE.x/2 + x, tile_pos.y-MAP_SIZE.y/2 + y),0 , Vector2(1, 1), 0)
#				cells.append(Vector2(tile_pos.x-MAP_SIZE.x/2 + x, tile_pos.y-MAP_SIZE.y/2 + y))
			else:
				set_cell(0, Vector2(tile_pos.x-MAP_SIZE.x/2 + x, tile_pos.y-MAP_SIZE.y/2 + y),0 , Vector2(0, 5), 0)
#	set_cells_terrain_connect(0, cells, 0, 0)
