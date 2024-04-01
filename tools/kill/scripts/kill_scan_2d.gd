# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node2D

signal killed()

const KillArea2D: = preload("kill_area_2d.gd")

@export_flags_2d_physics var collision_mask: int = 1 << 0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var dss: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask
	query.position = global_position
	query.exclude = []
	var collided: Array[CollisionObject2D] = []
	var query_results: Array[Dictionary] = dss.intersect_point(query)
	for query_result: Dictionary in query_results:
		var kill_area: KillArea2D = query_result[&"collider"] as KillArea2D
		if kill_area == null:
			continue
		killed.emit()
