# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Sprite2D

# plan:
# main map script tracks biome/"level" progress
# this will simply handle tiles
# main map script will set tile textures/ground artifacts when switching biomes

# this generates pseudorandom tile based on _tile_index
# _tile_index is incremented/decremented with _tile_scroll

# use hash() or rng?

@export var width: int = 8# size in tiles

var _tiles: Array[RID] = []

# when tile goes out of range, wrap around, set new texture

func _refresh_tiles() -> void:
	pass
	#RenderingServer.canvas_item_add_texture_rect()

func _ready() -> void:
	pass

const TILE_INDEX_RANGE: int = 256
var _tile_index: int = 0
var _tile_scroll: float = 0.0

func _draw() -> void:
	pass
	print("ah")

func scroll(delta: float) -> void:
	_tile_scroll += delta
	while _tile_scroll < 0.0:
		pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass#position.x
