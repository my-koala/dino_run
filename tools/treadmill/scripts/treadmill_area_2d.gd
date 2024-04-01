# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Area2D

const TreadmillCast2D: = preload("treadmill_cast_2d.gd")

var _speed: float = 0.0

func get_speed() -> float:
	return _speed
