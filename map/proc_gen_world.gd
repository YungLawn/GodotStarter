@tool
extends Node2D

@onready var tile_map = $TileMap

@export var noise_texture : NoiseTexture2D

@export var is_generating: bool
@export var is_clear: bool

@export var width : int = 50
@export var height : int =  50

var noise : Noise

var water_tile_atlas = Vector2i(0,1)
var tree_atlas = Vector2i(12,2)
var tree_atlas2 = Vector2i(15,6)

#TERRAIN ARR
var sand_arr = []
var grass_arr = []
var cliff_arr = []

#LAYERS
var water_layer = 0
var ground_1_layer = 1
var ground_2_layer = 2
var cliff_layer = 3
var environment_layer = 4

var random_grass_atlas_arr = [Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0)]

func _process(_delta):
		if Engine.is_editor_hint():
			if is_clear: 
				tile_map.clear()
				is_clear = false
			if is_generating:
				tile_map.clear()
				generate_world()
				is_generating = false

func _ready():
	noise = noise_texture.noise
	generate_world()

func generate_world():
	var noise_val
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			
			#setting cliffs
			if noise_val > 0.6:
				cliff_arr.append(Vector2(x,y))
			
			#setting all grass tiles
			if noise_val > 0.15:
				grass_arr.append(Vector2(x,y))
				#if noise_val > 0.3:
					##random grass
					#tile_map.set_cell(ground_2_layer, Vector2(x,y), 1,random_grass_atlas_arr.pick_random())
			# setting sand and palm trees between water and grass
			if noise_val > 0:
				sand_arr.append(Vector2(x,y))
				
			tile_map.set_cell(water_layer,Vector2i(x,y), 1,water_tile_atlas)

	tile_map.set_cells_terrain_connect(ground_1_layer, sand_arr, 3,0)
	tile_map.set_cells_terrain_connect(ground_1_layer, grass_arr, 1,0)
	#tile_map.set_cells_terrain_connect(cliff_layer,cliff_arr, 4,0)

