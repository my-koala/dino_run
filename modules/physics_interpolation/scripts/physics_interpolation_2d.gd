# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node2D
class_name PhysicsInterpolation2D

@export
var enabled: bool = true

var _transform_curr: Transform2D = Transform2D()
var _transform_prev: Transform2D = Transform2D()

func _init() -> void:
	set_process(true)
	set_physics_process(true)

func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		return
	
	if !enabled:
		return
	
	match what:
		NOTIFICATION_ENTER_TREE:
			teleport()
		NOTIFICATION_PHYSICS_PROCESS:
			_refresh_transform.call_deferred()
		NOTIFICATION_PROCESS:
			_apply_transform.call_deferred()

func teleport() -> void:
	_refresh_transform()
	_transform_prev = _transform_curr
	_apply_transform()

func _refresh_transform() -> void:
	var parent: Node2D = get_parent() as Node2D
	if parent == null:
		return
	
	_transform_prev = _transform_curr
	_transform_curr = parent.global_transform

func _apply_transform() -> void:
	var fraction: float = Engine.get_physics_interpolation_fraction()
	global_transform = _transform_prev.interpolate_with(_transform_curr, fraction)
