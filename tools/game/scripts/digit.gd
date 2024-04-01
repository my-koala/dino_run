# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends TextureRect

@onready var _texture: AtlasTexture = texture as AtlasTexture

@export var digit: int = 0:
	set(value):
		digit = clampi(value, 0, 10)
		if _texture == null:
			_texture = texture as AtlasTexture
		_texture.region.position.x = digit * 7
		queue_redraw()
