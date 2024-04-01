# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Node
class_name InputRelay

signal any_started()

signal jump_started()
signal jump_stopped()
var jump: bool = false:
	set(value):
		if jump != value:
			jump = value
			if jump:
				jump_started.emit()
				any_started.emit()
			else:
				jump_stopped.emit()

signal duck_started()
signal duck_stopped()
var duck: bool = false:
	set(value):
		if duck != value:
			duck = value
			if duck:
				duck_started.emit()
				any_started.emit()
			else:
				duck_stopped.emit()

signal invincibility_started()
signal invincibility_stopped()
var invincibility: bool = false:
	set(value):
		if invincibility != value:
			invincibility = value
			if invincibility:
				invincibility_started.emit()
				any_started.emit()
			else:
				invincibility_stopped.emit()

func _input(event: InputEvent) -> void:
	jump = Input.is_action_pressed(&"jump")
	duck = Input.is_action_pressed(&"duck")
	invincibility = Input.is_action_pressed(&"invincibility")
