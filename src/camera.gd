class_name Camera
extends Camera3D

@export var transition_speed: float = 1.0
@export var sensitivity: Vector2 = Vector2.ONE
@export var sensitivity_zoomed_multiplier: float = 2.0
@export var zoom_on_paint: float = 10.0
@export var zoom_speed: float = 10.0

var target_position: Node3D = null

@onready var _mouse: MouseInpt = $Mouse
@onready var _sensitivity: Vector2 = sensitivity

var _base_rotation: Vector3 = Vector3.ZERO
var _initial_fov: float = 0.0
var _is_zoomed: bool = false

func _ready():
	_base_rotation = global_rotation
	_initial_fov = fov

func _process(delta):
	_is_zoomed = _mouse.left

	_apply_rotation(delta)
	_apply_zoom(delta)
	_transition_to_target_position(delta)


func _transition_to_target_position(delta: float):
	if target_position == null:
		return

	global_position = lerp(global_position, target_position.global_position, transition_speed * delta)
	_base_rotation = _base_rotation.slerp(target_position.global_rotation, transition_speed * delta)

func _apply_rotation(delta: float):
	var target_sensitivity = sensitivity * sensitivity_zoomed_multiplier if _is_zoomed else sensitivity
	_sensitivity = lerp(_sensitivity, target_sensitivity, zoom_speed * delta)

	if target_position == null:
		return

	var rotation_offset := _mouse.from_center * _sensitivity
	global_rotation.x = _base_rotation.x - deg_to_rad(rotation_offset.y)
	global_rotation.y = _base_rotation.y - deg_to_rad(rotation_offset.x)

func _apply_zoom(delta: float):
	var target_fov = _initial_fov - zoom_on_paint if _is_zoomed else _initial_fov
	fov = lerp(fov, target_fov, zoom_speed * delta)
