# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends CharacterBody2D

# TODO:
# trex can jump and duck.
# and then hopefully shoot a shotgun later
# maybe dodge roll too? like iframe walls or cliffs or something lol
# animation drives treadmill speed? need acceleration component

# TODO: hold jump increases jump height (use attenuation or a curve)
# TODO: acceleration (only on ground)
# if time, gun will slow down trex when shooting
# TODO: scroll milestones?
# TODO: enum states for more control over state (low priority)
# TODO: speed to top speed should be asymptotic (reward staying on the ground)
# use equation like ax/(ax + 1) ? approach horizontal asymptote with time 0.0 to max
# TODO: white outline should disappear on death?

@onready var _animation_player: AnimationPlayer = $animation_player as AnimationPlayer
@onready var _physics_interpolation: PhysicsInterpolation2D = $physics_interpolation_2d as PhysicsInterpolation2D
@onready var _treadmill_cast: Tools.TreadmillCast2D = $treadmill_cast_2d as Tools.TreadmillCast2D
@onready var _hit_take_2d: Tools.HitTake2D = $hit_take_2d as Tools.HitTake2D
@onready var _input_relay: InputRelay = $input_relay as InputRelay
@onready var _game_actor: Tools.GameActor = $game_actor as Tools.GameActor
@onready var _sprite: Sprite2D = $physics_interpolation_2d/sprite_2d as Sprite2D
@onready var _audio_jump: AudioStreamPlayer = $audio_jump as AudioStreamPlayer
@onready var _audio_dead: AudioStreamPlayer = $audio_dead as AudioStreamPlayer

@export_range(0.0, 2.0) var gravity_scale: float = 1.0
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var _gravity_vector: Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity_vector") as Vector2

const MOVE_SPEED_MIN: float = 192.0# Minimum of move speed mapping
const MOVE_SPEED_MAX: float = 384.0# Maximum of move speed mapping
const MOVE_SPEED_TIME_MIN: float = 0.0
const MOVE_SPEED_TIME_MAX: float = 4294967296.0
const MOVE_SPEED_COEFFICIENT: float = 0.025# Coefficient of asymptotic equation thing (keep ratio)
var _move_speed_time: float = 0.0

var _jump: bool = false# set by input
@export_range(0.0, 1024.0) var jump_speed: float = 160.0
@export_range(0.0, 1024.0) var jump_hold_speed: float = 108.0
@export var jump_hold_curve: Curve = null
var _jump_hold: bool = false# true if jump has been continuously held since initial jump
@export_range(0.0, 1.0) var jump_hold_time: float = 0.50
var _jump_hold_time: float = 0.0
@export_range(0.0, 1.0) var jump_cooldown_time: float = 0.05
var _jump_cooldown_time: float = 0.0

var _duck: bool = false# set by input

@export var flop_speed: float = 80.0
var _flop: bool = false

var _await_jump: bool = true
var _reset_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_input_relay.jump_started.connect(_on_input_relay_jump_started)
	_input_relay.jump_stopped.connect(_on_input_relay_jump_stopped)
	_input_relay.duck_started.connect(_on_input_relay_duck_started)
	_input_relay.duck_stopped.connect(_on_input_relay_duck_stopped)
	_input_relay.invincibility_started.connect(_on_input_relay_invincibility_started)
	
	_game_actor.reset_requested.connect(reset)
	
	_reset_position = position
	
	_physics_interpolation.teleport()
	_animation_player.play(&"trex_default/stand_idle")
	_await_jump = true
	_hit_take_2d.restore()

func _on_input_relay_jump_started() -> void:
	_jump = true

func _on_input_relay_jump_stopped() -> void:
	_jump = false

func _on_input_relay_duck_started() -> void:
	_duck = true

func _on_input_relay_duck_stopped() -> void:
	_duck = false

func _on_input_relay_invincibility_started() -> void:
	_hit_take_2d.monitoring = !_hit_take_2d.monitoring

func reset() -> void:
	pass# TODO: reset speed, acceleration stuff, animation, position
	position = _reset_position
	_physics_interpolation.teleport()
	_animation_player.play(&"trex_default/stand_idle")
	_move_speed_time = 0.0
	_hit_take_2d.restore()
	_emit_dead_once = false

var _emit_dead_once: bool = false
# code is mess
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var animation: StringName = _animation_player.current_animation
	
	#var gravity_velocity: Vector2 = Vector2.ZERO
	#if velocity.dot(_gravity_vector) < 0.0:
	#	gravity_velocity = velocity.project(_gravity_vector)
	var gravity_velocity: Vector2 = _gravity * gravity_scale * _gravity_vector.normalized()
	#if velocity.dot(_gravity_vector) < 0.0:
	#	gravity_velocity += velocity.project(_gravity_vector)
	var move_velocity: Vector2 = Vector2.ZERO
	
	# TODO: velocity stuff aint right bro: inconsistent with different physics fps
	
	if _await_jump:
		_move_speed_time = 0.0
	elif !is_zero_approx(_move_speed_time):
		var fraction: float = (MOVE_SPEED_COEFFICIENT * _move_speed_time) / ((MOVE_SPEED_COEFFICIENT * _move_speed_time) + 1)
		move_velocity = Vector2.RIGHT * lerpf(MOVE_SPEED_MIN, MOVE_SPEED_MAX, clampf(fraction, 0.0, 1.0))
	
	var jump_velocity: Vector2 = Vector2.ZERO
	
	var shader_material: ShaderMaterial = _sprite.material as ShaderMaterial
	if _hit_take_2d.is_dead():
		# still no enum state :(
		match animation:
			&"RESET", &"trex_default/stand_idle", &"trex_default/stand_move":
				animation = &"trex_default/stand_dead"
			&"trex_default/duck_idle", &"trex_default/duck_move":
				animation = &"trex_default/duck_dead"
			&"trex_default/jump":
				animation = &"trex_default/jump_dead"
			&"trex_default/flop":
				animation = &"trex_default/flop_dead"
		move_velocity = Vector2.ZERO
	elif is_on_floor():
		_move_speed_time = maxf(_move_speed_time + delta, 0.0001)
		_flop = false
		_jump_hold = false
		if _jump_cooldown_time < jump_cooldown_time:
			_jump_cooldown_time += delta
		if _duck:
			if is_zero_approx(move_velocity.x):
				animation = &"trex_default/duck_idle"
			else:
				animation = &"trex_default/duck_move"
		elif _jump && _jump_cooldown_time >= jump_cooldown_time:
			_await_jump = false
			_jump_cooldown_time = 0.0
			if !_jump_hold:
				_audio_jump.play()
			_jump_hold = true
			_jump_hold_time = 0.0
			jump_velocity += Vector2.UP * jump_speed
			animation = &"trex_default/jump"
		else:
			if is_zero_approx(move_velocity.x):
				animation = &"trex_default/stand_idle"
			else:
				animation = &"trex_default/stand_move"
	else:
		_jump_hold = _jump_hold && _jump
		if _duck && !_flop:
			_jump_hold = false
			_flop = true# spontaneously gain weight
			jump_velocity += Vector2.DOWN * flop_speed
			animation = &"trex_default/flop"
		elif _jump_hold && (_jump_hold_time < jump_hold_time):
			var frac: float = clampf(_jump_hold_time / jump_hold_time, 0.0, 1.0)
			#var weight: float = 1.0 - pow(frac, 1.0 / jump_hold_curve)
			var weight: float = jump_hold_curve.sample(frac)
			jump_velocity += Vector2.UP * jump_hold_speed * weight
			_jump_hold_time += delta
			animation = &"trex_default/jump"
	
	if !_hit_take_2d.is_dead():
		_game_actor.current_speed = move_velocity.x
	elif !_emit_dead_once:
		_audio_dead.play()
		_game_actor.died.emit()
		_emit_dead_once = true
	
	#velocity += delta * gravity_velocity
	#velocity += jump_velocity
	velocity += delta * gravity_velocity + jump_velocity
	move_and_slide()
	
	_treadmill_cast.speed = move_velocity.x
	
	if _animation_player.current_animation != animation:
		_animation_player.play(animation)
