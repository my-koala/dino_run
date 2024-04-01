# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends _BASE_

func _ready() -> void:
	if Engine.is_editor_hint():
		return

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
