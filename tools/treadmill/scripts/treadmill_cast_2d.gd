# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node2D

const TreadmillArea2D: = preload("treadmill_area_2d.gd")
const DISTANCE_THRESHOLD: float = 0.125

@export var down_direction: Vector2 = Vector2.DOWN:
	set(value):
		value = value.normalized()
		if !value.is_zero_approx():
			down_direction = value

@export var speed: float = 0.0

@export_flags_2d_physics var collision_mask: int = 1 << 0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var dss: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask
	query.hit_from_inside = true
	query.from = global_position
	query.to = global_position + (down_direction * DISTANCE_THRESHOLD)
	query.exclude = []
	var query_result: Dictionary = dss.intersect_ray(query)
	if query_result.is_empty():
		return
	var treadmill_area: TreadmillArea2D = query_result[&"collider"] as TreadmillArea2D
	if treadmill_area != null:
		treadmill_area._speed = speed
