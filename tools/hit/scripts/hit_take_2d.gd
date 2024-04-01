# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Area2D

const HitGive2D: = preload("hit_give_2d.gd")

# Simple hit logic #

# TODO: invincibility frames on hurted?
# or maybe add collision exception temporarily? probably not

signal healed(amount: int)
signal hurted(amount: int)# ouch
signal deaded()
signal alived()

@export var max_health: int = 3:
	set(value):
		max_health = mini(1, value)

var _health: int
func get_health() -> int:
	return _health

func is_dead() -> bool:
	return _health == 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_health = max_health
	area_entered.connect(_on_area_entered)

func restore() -> void:
	var dead: bool = _health == 0
	_health = max_health
	if dead:
		alived.emit()# hallelujah

# subtracts damage from health (use negative damage for healing)
# returns actual amount of damage applied
func apply_damage(damage: int) -> int:
	if _health == 0:
		return 0
	
	var health: int = clampi(_health - damage, 0, max_health)
	var actual_damage: int = _health - health
	_health = health
	if actual_damage < 0:
		healed.emit(actual_damage)
	elif actual_damage > 0:
		hurted.emit(actual_damage)
	if _health == 0:
		deaded.emit()
	return actual_damage

func _on_area_entered(area: Area2D) -> void:
	if area.owner == owner:
		return
	var hit_give: HitGive2D = area as HitGive2D
	if hit_give == null:
		return
	var damage: int = apply_damage(hit_give.damage)
	if damage != 0:
		hit_give.hit_given.emit(damage)
