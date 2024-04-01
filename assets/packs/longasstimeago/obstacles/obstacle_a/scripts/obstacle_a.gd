# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends StaticBody2D

@onready var _physics_interpolation: PhysicsInterpolation2D = $physics_interpolation_2d as PhysicsInterpolation2D
@onready var _kill_scan: Tools.KillScan2D = $kill_scan_2d as Tools.KillScan2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_kill_scan.killed.connect(_on_killscan_killed)

func _on_killscan_killed() -> void:
	queue_free()
