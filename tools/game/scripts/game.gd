# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node

const GameActor: = preload("game_actor.gd")
const GameMap: = preload("game_map.gd")
const DigitDisplay: = preload("digit_display.gd")

@onready var _input_relay: InputRelay = $input_relay as InputRelay
@onready var _gui_distance: DigitDisplay = $gui/control/distance as DigitDisplay
@onready var _gui_speed: DigitDisplay = $gui/control/speed as DigitDisplay
@onready var _gui_game_over: Control = $gui/control/game_over as Control
@onready var _gui_retry: Control = $gui/control/retry as Control

@onready var _state_cover_a: Sprite2D = $start_cover as Sprite2D
@onready var _state_cover_b: ColorRect = $gui/control/start_cover as ColorRect

@export var protagonist: Node = null
@export var map: Node = null

var _protagonist: GameActor = null
var _map: GameMap = null

func _ready() -> void:
	_protagonist = protagonist.get_node_or_null("game_actor") as GameActor
	_map = map.get_node_or_null("game_map") as GameMap
	_protagonist.died.connect(_on_protagonist_died)
	_input_relay.any_started.connect(_on_input_relay_any_started)

var _game_over: bool = false
func _on_protagonist_died() -> void:
	_game_over = true

var _game_reset: bool = false
func _on_input_relay_any_started() -> void:
	if _await_start:
		var tween: Tween = create_tween()
		tween.tween_property(_state_cover_a, "position:x", 256.0, 0.75)
		tween.parallel()
		tween.tween_property(_state_cover_b, "position:x", 256.0, 0.75)
		
		_await_start = false
	if _game_over:
		_game_reset = true

var _await_start: bool = true
var _reset_once: bool = false# temporary
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# temporary #
	if Input.is_key_pressed(KEY_R):
		if !_reset_once:
			_reset_once = true
			if _protagonist != null:
				_protagonist.reset_requested.emit()
			if _map != null:
				_map.reset_requested.emit()
	else:
		_reset_once = false
	# temporary #
	
	if _await_start:
		return
	
	_gui_distance.number = _map.current_distance
	_gui_speed.number = int(_protagonist.current_speed)
	
	if _game_over:
		_gui_game_over.visible = true
		_gui_retry.visible = true
		if _game_reset:
			_map.reset_requested.emit()
			_protagonist.reset_requested.emit()
			_game_over = false
			_game_reset = false
	else:
		_gui_game_over.visible = false
		_gui_retry.visible = false
