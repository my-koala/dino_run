# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends SubViewport
class_name BetterSubViewport

# Better SubViewport that preserves scale with Window resize #
# Make sure to use Window stretch mode canvas_items in Project Settings #

var _root: Window = null

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	_root = get_tree().root
	_root.size_changed.connect(_on_root_size_changed)
	_on_root_size_changed()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	
	_root.size_changed.disconnect(_on_root_size_changed)
	_on_root_size_changed()
	_root = null

func _on_root_size_changed() -> void:
	size_2d_override_stretch = true
	size_2d_override = _root.content_scale_size
