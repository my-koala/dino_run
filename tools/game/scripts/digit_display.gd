# Code by Valedict (git: valedict0) copyrighted LUL
@tool
extends Control

const Digit: = preload("digit.gd")

@onready var _digit_container: HBoxContainer = $h_box_container as HBoxContainer
var _digits: Array[Digit] = []

@export var number: int = 0:
	set(value):
		value = maxi(0, value)
		if number != value:
			number = value
			if is_node_ready():
				refresh_digits()

func _ready() -> void:
	for node: Node in _digit_container.get_children():
		var digit: Digit = node as Digit
		if digit == null:
			continue
		_digits.append(digit)
	refresh_digits()

func refresh_digits() -> void:
	var digits: Array[int] = []
	var number_temp: int = number
	if number_temp == 0:
		digits.append(0)
	while number_temp > 0:
		digits.insert(0, number_temp % 10)
		number_temp = int(float(number_temp) / 10.0)
	var digit_index: int = 0
	while digit_index < digits.size():
		_digits[digit_index].digit = digits[digit_index]
		digit_index += 1
	while digit_index < _digits.size():
		_digits[digit_index].digit = 10
		digit_index += 1
