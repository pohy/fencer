class_name MouseInpt
extends Node

signal on_motion
signal on_click

var left: bool = false
var left_pressed: bool = false
var left_released: bool = false
var right: bool = false
var right_pressed: bool = false
var right_released: bool = false
var pos: Vector2 = Vector2.ZERO
var from_center: Vector2 = Vector2.ZERO
var delta: Vector2 = Vector2.ZERO
var is_moving: bool = false

@onready var window_size: Vector2

var _last_pos: Vector2 = Vector2.ZERO


func _ready():
	pos = get_viewport().get_mouse_position()
	window_size = get_viewport().get_size()


func _process(_delta):
	is_moving = false
	delta = Vector2.ZERO

	left_pressed = false
	left_released = false
	right_pressed = false
	right_released = false


func _input(event):
	if event is InputEventMouseMotion:
		is_moving = true
		delta = event.relative

		pos += delta
		pos.x = clamp(pos.x, 0, window_size.x)
		pos.y = clamp(pos.y, 0, window_size.y)

		from_center = (pos / window_size) * 2 - Vector2.ONE
		_last_pos = pos

		on_motion.emit()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left = event.is_pressed() and not event.is_released()
			left_pressed = event.is_pressed()
			left_released = event.is_released()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			right = event.is_pressed() and not event.is_released()
			right_pressed = event.is_pressed()
			right_released = event.is_released()
		on_click.emit()
