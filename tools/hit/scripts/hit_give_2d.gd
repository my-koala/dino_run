# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Area2D

const HitTake2D: = preload("hit_take_2d.gd")

# Simple hit logic #

signal hit_given(amount: int)

@export var damage: int = 1

var _global_transform_prev: Transform2D = Transform2D()
func _enter_tree() -> void:
	_global_transform_prev = global_transform

var _shapes: Array[Shape2D] = []
func _ready() -> void:
	for shape_owner: int in get_shape_owners():
		for shape: int in shape_owner_get_shape_count(shape_owner):
			_shapes.append(shape_owner_get_shape(shape_owner, shape))
	
	#print(_shapes)

func _physics_process(delta: float) -> void:
	return# TODO: ???????
	#shape_owner_get_shape()
	var collided: Array[CollisionObject2D] = []
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask
	query.exclude = []
	query.margin = 0.1
	query.motion = global_transform.origin - _global_transform_prev.origin
	query.transform = _global_transform_prev
	for shape_owner: int in get_shape_owners():
		for shape: int in shape_owner_get_shape_count(shape_owner):
			query.shape = shape_owner_get_shape(shape_owner, shape)
			query.motion = global_transform.origin - _global_transform_prev.origin
	#get_shape_owners()
