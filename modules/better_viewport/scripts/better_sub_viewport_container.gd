# Code by Valedict (git: valedict0)
@tool
extends SubViewportContainer
class_name BetterSubViewportContainer

# Better SubViewportContainer that properly resizes with Window #
# Make sure to use Window stretch mode canvas_items in Project Settings #

var _root: Window = null

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)

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
	size = _root.size
	scale = Vector2(_root.content_scale_size) / Vector2(_root.size)
