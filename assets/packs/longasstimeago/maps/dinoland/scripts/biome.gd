# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node2D

# NOTE: do not mask spawner/obstacles
# use rect as mask? not good. think camera shake?

# dinoland phys:
# update scroll of self, updating distance/timer
# update scroll of current biome. returns true on end
# if true, 

# TODO: what if this handled everything spawner/geometry related?
#const BiomeSpawner: = preload("biome_spawner.gd")
#const BiomeGeometry: = preload("biome_geometry.gd")
#@onready var _spawner: BiomeSpawner = null
#@onready var _geometry: BiomeGeometry = null

# plan:
# scroll ends set by dinoland
# determines visibility

# Cool constants !
const GROUND_LEVEL: float = 90.0
const SPAWNER_PADDING_L: int = 64# Distance from end a to start spawning obstacles
const SPAWNER_PADDING_R: int = 64# Distance from end b to stop spawning obstacles
const SPAWNER_BOUND_L: int = 384# Distance from scroll (origin) to instantiate obstacles
const SPAWNER_BOUND_R: int = 512# Distance from scroll (origin) to instantiate obstacles
const DISPLAY_BOUND_L: float = -128.0
const DISPLAY_BOUND_R: float = 384.0

# Obstacles !
const ObstacleA: = preload("../../../obstacles/obstacle_a/scripts/obstacle_a.gd")
const OBSTACLE_A_0: PackedScene = preload("../../../obstacles/obstacle_a/obstacle_a_0.tscn")
const OBSTACLE_A_1: PackedScene = preload("../../../obstacles/obstacle_a/obstacle_a_1.tscn")
const OBSTACLE_A_2: PackedScene = preload("../../../obstacles/obstacle_a/obstacle_a_2.tscn")
const OBSTACLE_A_3: PackedScene = preload("../../../obstacles/obstacle_a/obstacle_a_3.tscn")
const OBSTACLE_A: Array[PackedScene] = [OBSTACLE_A_0, OBSTACLE_A_1, OBSTACLE_A_2, OBSTACLE_A_3]

const ObstacleB: = preload("../../../obstacles/obstacle_b/scripts/obstacle_b.gd")
const OBSTACLE_B: PackedScene = preload("../../../obstacles/obstacle_b/obstacle_b.tscn")

const ObstacleC: = preload("../../../obstacles/obstacle_c/scripts/obstacle_c.gd")
const OBSTACLE_C: PackedScene = preload("../../../obstacles/obstacle_c/obstacle_c.tscn")

# Set by dinoland.gd in physics_process
var scroll_end_l: int = 0# Scroll start position of biome
var scroll_end_r: int = 0# Scroll end position of biome
func set_scroll(scroll: int, scroll_frac: float) -> void:
	_scroll = scroll
	_scroll_frac = scroll_frac
var _scroll: int = 0
var _scroll_frac: float = 0.0

# Track current and previous scroll for interpolation
var _scroll_curr: int = 0
var _scroll_frac_curr: float = 0.0
var _scroll_prev: int = 0
var _scroll_frac_prev: float = 0.0

var _fnl: FastNoiseLite = null# Pseudorandom stuff
func _init() -> void:
	_fnl = FastNoiseLite.new()
	_fnl.seed = 0
	_fnl.frequency = 1.0
	_fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX# could use value too
	_fnl.fractal_type = FastNoiseLite.FRACTAL_NONE

@warning_ignore("shadowed_global_identifier")
func set_seed(seed: int) -> void:
	_fnl.seed = seed

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Refresh scroll
	_scroll_prev = _scroll_curr
	_scroll_frac_prev = _scroll_frac_curr
	_scroll_curr = _scroll
	_scroll_frac_curr = _scroll_frac
	#print("biome physics: %.5f to %.5f" % [_scroll_prev + _scroll_frac_prev, _scroll_curr + _scroll_frac_curr])
	_update_spawner(_scroll_curr, _scroll_frac_curr)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Interpolation !
	var fraction: float = Engine.get_physics_interpolation_fraction()
	var scroll_delta: float = float(_scroll_curr - _scroll_prev) + (_scroll_frac_curr - _scroll_frac_prev)
	var scroll: int = _scroll_prev + int(scroll_delta * fraction)
	var scroll_frac: float = _scroll_frac_prev + fmod(scroll_delta * fraction, 1.0)
	#print("scroll: %.5f : %.5f to %.5f : f: %.5f" % [scroll + scroll_frac, _scroll_prev + _scroll_frac_prev, _scroll_curr + _scroll_frac_curr, fraction])
	_update_display(scroll, scroll_frac)

# TODO: Implement in extending biome scripts
func _update_display(scroll: int, scroll_frac: float) -> void:
	pass

func _update_spawner(scroll: int, scroll_frac: float) -> void:
	pass

func reset() -> void:
	pass# TODO: this lul
