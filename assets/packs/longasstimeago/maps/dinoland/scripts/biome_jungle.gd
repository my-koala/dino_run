# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends "biome.gd"

var _spawn_ground: int = 0# ground
var _spawn_sky: int = 0# air

const SPAWNER_GROUND_COOLDOWN_MIN: int = 720
const SPAWNER_GROUND_COOLDOWN_MAX: int = 1300
const SPAWNER_SKY_COOLDOWN_MIN: int = 128
const SPAWNER_SKY_COOLDOWN_MAX: int = 300
const SPAWNER_SKY_SCROLL_THRESHOLD: int = 0
const SPAWNER_SKY_HEIGHT_MIN: float = 20.0
const SPAWNER_SKY_HEIGHT_MAX: float = 72.0
const SPAWNER_GROUND_SKY_DISTANCE_MIN: int = 64# distance between sky and ground spawning

@onready var _display: Sprite2D = $display as Sprite2D
@onready var _spawner: Node2D = $spawner as Node2D
@onready var _display_grass: Parallax2D = $display/grass as Parallax2D
@onready var _display_clouds: Parallax2D = $display/clouds as Parallax2D
@onready var _display_trees: Parallax2D = $display/trees as Parallax2D
@onready var _display_transition: Sprite2D = $display/transition as Sprite2D

func _update_display(scroll: int, scroll_frac: float) -> void:
	_display.offset.x = clampf(float(scroll_end_l - scroll) - scroll_frac, DISPLAY_BOUND_L, DISPLAY_BOUND_R)
	_display.region_rect.size.x = clampf(float(scroll_end_r - scroll) - scroll_frac - DISPLAY_BOUND_L, DISPLAY_BOUND_L, DISPLAY_BOUND_R)
	var ground_size: int = int(_display_grass.repeat_size.x / _display_grass.scroll_scale.x)
	_display_grass.screen_offset.x = fmod(float(scroll % ground_size) + scroll_frac, ground_size)
	var display_trees_size: int = int(_display_trees.repeat_size.x / _display_trees.scroll_scale.x)
	_display_trees.screen_offset.x = fmod(float(scroll % display_trees_size) + scroll_frac, display_trees_size)
	var sky_size: int = int(_display_clouds.repeat_size.x / _display_clouds.scroll_scale.x)
	_display_clouds.screen_offset.x = fmod(float(scroll % sky_size) + scroll_frac, sky_size)
	_display_transition.position.x = float(scroll_end_l - scroll) - scroll_frac
	_display_transition.visible = scroll > 32# hack

func _update_spawner(scroll: int, scroll_frac: float) -> void:
	for node: Node in _spawner.get_children():
		var node_2d: Node2D = node as Node2D
		if node_2d == null:
			continue
		node_2d.position.x -= float(_scroll_curr - _scroll_prev) + (_scroll_frac_curr - _scroll_frac_prev)
	
	# region bounds for spawning
	var spawn_bound_l: int = maxi(scroll + SPAWNER_BOUND_L, scroll_end_l + SPAWNER_PADDING_L)
	var spawn_bound_r: int = mini(scroll + SPAWNER_BOUND_R, scroll_end_r - SPAWNER_PADDING_R)
	
	if (spawn_bound_r - spawn_bound_l) <= 0:
		return
	
	if _spawn_ground < scroll_end_l:
		_spawn_ground = scroll_end_l# reference lend end of biome for spawn point generation
	while _spawn_ground < spawn_bound_l:
		var fraction: float = fposmod(_fnl.get_noise_1d(float(hash(_spawn_ground))), 1.0)
		_spawn_ground += int(lerpf(float(SPAWNER_GROUND_COOLDOWN_MIN), float(SPAWNER_GROUND_COOLDOWN_MAX), fraction))
		# skip to next spawn point
		# quick hack for more fair spawning
		if absi(_spawn_ground - _spawn_sky) < SPAWNER_GROUND_SKY_DISTANCE_MIN:
			if _spawn_ground < _spawn_sky:
				_spawn_sky += SPAWNER_GROUND_SKY_DISTANCE_MIN
			else:
				_spawn_ground += SPAWNER_GROUND_SKY_DISTANCE_MIN
	while _spawn_ground < spawn_bound_r:
		var obstacle: ObstacleC = OBSTACLE_C.instantiate() as ObstacleC
		obstacle.position.x = float(_spawn_ground - scroll) + scroll_frac
		obstacle.position.y = GROUND_LEVEL
		_spawner.add_child(obstacle)
		
		var fraction: float = fposmod(_fnl.get_noise_1d(float(_spawn_ground)), 1.0)
		_spawn_ground += int(lerpf(float(SPAWNER_GROUND_COOLDOWN_MIN), float(SPAWNER_GROUND_COOLDOWN_MAX), fraction))
		# quick hack for more fair spawning
		if absi(_spawn_ground - _spawn_sky) < SPAWNER_GROUND_SKY_DISTANCE_MIN:
			if _spawn_ground < _spawn_sky:
				_spawn_sky += SPAWNER_GROUND_SKY_DISTANCE_MIN
			else:
				_spawn_ground += SPAWNER_GROUND_SKY_DISTANCE_MIN
	
	if _spawn_sky < scroll_end_l:
		_spawn_sky = scroll_end_l
	while _spawn_sky < spawn_bound_l:
		var fraction: float = fposmod(_fnl.get_noise_1d(float(hash(_spawn_sky))), 1.0)
		_spawn_sky += int(lerpf(float(SPAWNER_SKY_COOLDOWN_MIN), float(SPAWNER_SKY_COOLDOWN_MAX), fraction))
		# quick hack for more fair spawning
		if absi(_spawn_ground - _spawn_sky) < SPAWNER_GROUND_SKY_DISTANCE_MIN:
			if _spawn_ground < _spawn_sky:
				_spawn_sky += SPAWNER_GROUND_SKY_DISTANCE_MIN
			else:
				_spawn_ground += SPAWNER_GROUND_SKY_DISTANCE_MIN
	while _spawn_sky < spawn_bound_r && _spawn_sky > SPAWNER_SKY_SCROLL_THRESHOLD:
		var obstacle: ObstacleB = OBSTACLE_B.instantiate() as ObstacleB
		var fraction_height: float = fposmod(_fnl.get_noise_1d(float(_spawn_sky) / 2.0), 1.0)
		var random_height: float = lerpf(SPAWNER_SKY_HEIGHT_MIN, SPAWNER_SKY_HEIGHT_MAX, fraction_height)
		obstacle.position.x = float(_spawn_sky - scroll) + scroll_frac
		obstacle.position.y = random_height
		_spawner.add_child(obstacle)
		
		var fraction: float = fposmod(_fnl.get_noise_1d(float(_spawn_sky)), 1.0)
		_spawn_sky += int(lerpf(float(SPAWNER_SKY_COOLDOWN_MIN), float(SPAWNER_SKY_COOLDOWN_MAX), fraction))
		# quick hack for more fair spawning
		if absi(_spawn_ground - _spawn_sky) < SPAWNER_GROUND_SKY_DISTANCE_MIN:
			if _spawn_ground < _spawn_sky:
				_spawn_sky += SPAWNER_GROUND_SKY_DISTANCE_MIN
			else:
				_spawn_ground += SPAWNER_GROUND_SKY_DISTANCE_MIN

func reset() -> void:
	_spawn_ground = 0
	_spawn_sky = 0
	for obstacle: Node in _spawner.get_children():
		obstacle.queue_free()
