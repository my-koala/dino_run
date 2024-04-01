# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Tools.Map2D

# order of stuff
# dinoland sets biomes enabled and their visibility rects
# for transitions between biomes, need something to obstruct edge
# biomes have two distinct parts: spawner (obstacles) and geometry (visuals)

const Biome: = preload("biome.gd")

@onready var _treadmill_area: Tools.TreadmillArea2D = $treadmill_area_2d as Tools.TreadmillArea2D
@onready var _game_map: Tools.GameMap = $game_map as Tools.GameMap

const FIRST_BIOME_INDEX: int = 0
const FIRST_BIOME_END_L: int = 0
const FIRST_BIOME_END_R: int = 2048

const BIOME_LENGTH_MIN: int = 2048
const BIOME_LENGTH_MAX: int = 6000

var _biome_curr: Biome = null
var _biome_next: Biome = null
var _biomes: Array[Biome] = []

# TODO: set by game? date and time?
var master_seed: int = hash("koalas")

var _fnl: FastNoiseLite = null# Pseudorandom stuff
func _init() -> void:
	if Engine.is_editor_hint():
		return
	
	_fnl = FastNoiseLite.new()
	_fnl.seed = 0
	_fnl.frequency = 1.0
	_fnl.noise_type = FastNoiseLite.TYPE_SIMPLEX# could use value too
	_fnl.fractal_type = FastNoiseLite.FRACTAL_NONE

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_game_map.reset_requested.connect(reset)
	
	var biomes: Node2D = get_node_or_null("biomes") as Node2D
	for node: Node in biomes.get_children():
		var biome: Biome = node as Biome
		if biome == null:
			continue
		_biomes.append(biome)
	reset()

# Called by Game script (ready too!)
func reset() -> void:
	_scroll = 0
	_scroll_frac = 0.0
	_fnl.seed = master_seed
	for biome: Biome in _biomes:
		biome.reset()
		biome.set_seed(master_seed + hash(" are cute"))
		biome.set_scroll(_scroll, _scroll_frac)
		biome.scroll_end_l = 0
		biome.scroll_end_r = 0
		biome.visible = false
	_biome_curr = null
	_biome_next = _biomes[FIRST_BIOME_INDEX]
	_biome_next.scroll_end_l = FIRST_BIOME_END_L
	_biome_next.scroll_end_r = FIRST_BIOME_END_R
	_biome_next.visible = true

func get_biome(scroll: int) -> Biome:
	var rng: int = hash(_fnl.get_noise_1d(scroll))
	var biome: int = posmod(rng, _biomes.size())
	while _biomes.size() > 1 && _biomes[biome] == _biome_curr:
		biome = posmod(biome + 1, _biomes.size())
	return _biomes[biome]

func get_biome_length(scroll: int) -> int:
	var rng: float = absf(_fnl.get_noise_1d(scroll))
	return int(rng * float(BIOME_LENGTH_MAX - BIOME_LENGTH_MIN)) + BIOME_LENGTH_MIN

var _scroll: int = 0
var _scroll_frac: float = 0.0
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var scroll_delta: float = _treadmill_area.get_speed() * delta
	var new_scroll: int = _scroll + int(_scroll_frac + scroll_delta)
	var new_scroll_frac: float = fmod(_scroll_frac + scroll_delta, 1.0)
	
	if (new_scroll < _scroll) && (scroll_delta > 0.0):
		pass# TODO: handle positive integer overflow for the hardcore gamers?
	elif (new_scroll > _scroll) && (scroll_delta < 0.0):
		pass# TODO: dont handle negative integer overflow. dinosaurs dont run backwards
	
	_scroll = new_scroll
	_scroll_frac = new_scroll_frac
	
	# TODO: the next biome needs to have their ends set properly for drawing
	while _biome_curr == null || _scroll >= _biome_curr.scroll_end_r:
		_biome_curr = _biome_next
		_biome_curr.visible = true# redundant?
		var end: int = _biome_curr.scroll_end_r
		_biome_next = get_biome(end)
		_biome_next.scroll_end_l = end
		_biome_next.scroll_end_r = end + get_biome_length(end)# TODO: clamp to max integer for overflow ?
		_biome_next.visible = true
	
	#print("dinoland physics: %.5f : %.5f %.5f %.5f" % [_scroll + _scroll_frac, scroll_delta, delta, _treadmill_area.get_scroll_speed()])
	for biome: Biome in _biomes:
		biome.set_scroll(_scroll, _scroll_frac)
	_game_map.current_distance = _scroll

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if OS.is_debug_build():
		var label: Label = get_node_or_null("debug/label") as Label
		label.text = ""
		label.text += str(Engine.get_frames_per_second()) + "\n"
		label.text += "scroll: %d + %.2f\n" % [_scroll, _scroll_frac]
		label.text += "current biome: %s (%d, %d)\n" % [_biome_curr.name, _biome_curr.scroll_end_l, _biome_curr.scroll_end_r]

