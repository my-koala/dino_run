# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends StaticBody2D

const MOVE_SPEED: float = 16.0

@onready var _animation_player: AnimationPlayer = $animation_player as AnimationPlayer
@onready var _hit_give: Tools.HitGive2D = $hit_give_2d as Tools.HitGive2D
@onready var _kill_scan: Tools.KillScan2D = $kill_scan_2d as Tools.KillScan2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_animation_player.play(&"obstacle_b_default/fly")
	_hit_give.hit_given.connect(_on_hit_give_hit_given)
	_kill_scan.killed.connect(_on_killscan_killed)

func _on_killscan_killed() -> void:
	queue_free()

var _is_dead: bool = false
func _on_hit_give_hit_given(damage: int) -> void:
	_is_dead = true

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var animation: StringName = _animation_player.current_animation
	if _is_dead:
		animation = &"obstacle_b_default/dead"
	else:
		#position.x -= MOVE_SPEED * delta
		animation = &"obstacle_b_default/fly"
	if _animation_player.current_animation != animation:
		_animation_player.play(animation)
