extends Node3D

@export var brush_speed: float = 1.0
@export var depletion_rate: float = 1.0
@export var apply_interval_s: float = 0.1
@export var apply_velocity_multiplier: float = 1.0
@export var tilt_amount: float = 10.0

@onready var _mouse: MouseInpt = $Mouse
@onready var _brush_model: Node3D = $BrushModel
@onready var _brush_fill_progress: ProgressBar = $BrushModel/SubViewport/ProgressBar


var _target_cursor_position: Vector2 = Vector2.ZERO
var _current_cursor_position: Vector2 = Vector2.ZERO
var _paint_fill: float = 1.0
var _distance_travelled: float = 0.0
var _since_last_application_s: float = 0.0
var _brush_initial_basis: Basis = Basis.IDENTITY
var _is_above_plank: bool = false
var _mouse_position_3d: Vector3 = Vector3.ZERO
var _current_plank: Plank = null
var _target_brush_position: Vector3 = Vector3.ZERO

func _ready():
	_brush_initial_basis = Basis(_brush_model.basis)

func _process(delta):
	_target_cursor_position = _mouse.position
	var move_delta = _current_cursor_position - _target_cursor_position
	var velocity = move_delta.length()
	_current_cursor_position -= move_delta
	_distance_travelled += velocity

	_apply_tilt(delta, move_delta, velocity)
	_update_application_timers(delta, velocity)

	# TODO: Refill from a coloured bucket
	if _mouse.left_released:
		_paint_fill = 1.0

	_update_brush_position(delta)
	_apply_brush_stroke(delta, move_delta, velocity)

	_brush_fill_progress.value = _paint_fill

func _update_brush_position(delta: float):
	var camera := get_viewport().get_camera_3d()
	var origin := camera.project_ray_origin(_current_cursor_position)
	var direction := camera.project_ray_normal(_current_cursor_position)
	var to := origin + direction * 1000
	var query_params := PhysicsRayQueryParameters3D.create(origin, to)
	var query := get_world_3d().direct_space_state.intersect_ray(query_params)

	# if query.size() <= 0:
	# 	# _brush_model.global_position = origin + direction * 1.5
	# 	_target_brush_position = origin + direction
	_is_above_plank = query.size() > 0 and query.collider is Plank

	if _is_above_plank:
		_mouse_position_3d = query.position
		# _brush_model.global_position = query.position + query.normal * 0.1
		var distance_from_plank = 0.05 if _mouse.left else 0.18
		_target_brush_position = query.position + query.normal * distance_from_plank
		_current_plank = query.collider# if _is_above_plank else null

	if not _is_above_plank and not _mouse.left:
		# print_debug("nulling current plank")
		_current_plank = null
		_target_brush_position = origin + direction

	# print_debug("Target brush position: %s, query: %s" % [_target_brush_position, query])

	_brush_model.global_position = lerp(_brush_model.global_position, _target_brush_position, brush_speed * delta)
	

func _apply_brush_stroke(delta: float, move_delta: Vector2, velocity: float):
	if not _is_above_plank or _current_plank == null:
		return

	if _mouse.left and _since_last_application_s <= 0.0 and velocity > 0.0:
		var paint_used = depletion_rate * velocity * apply_velocity_multiplier * delta
		# TODO: Pass current paint color
		var dir_rotation = rad_to_deg(atan2(move_delta.y, move_delta.x)) - 90

		_current_plank.stroke_brush(_mouse_position_3d, _paint_fill * 0.1, dir_rotation)
		_paint_fill = max(0.0, _paint_fill - paint_used)

func _update_application_timers(delta: float, velocity: float):
	if _mouse.left:
		_since_last_application_s += delta
	else:
		_since_last_application_s = 0.0
	var current_apply_interval_s = apply_interval_s / max(1, velocity)
	if _since_last_application_s > current_apply_interval_s:
		_since_last_application_s = 0.0


func _apply_tilt(delta: float, move_delta: Vector2, velocity: float):
	# TODO: The velocity is resolution dependent
	var tilt_amount_rad = deg_to_rad(min(tilt_amount, velocity * (10 if _mouse.left else 2)))
	var target_basis = _brush_initial_basis \
		.rotated(_brush_initial_basis.z, move_delta.normalized().x * tilt_amount_rad) \
		.rotated(_brush_initial_basis.x, -move_delta.normalized().y * tilt_amount_rad)
	_brush_model.basis = _brush_model.basis.slerp(target_basis, delta * max(10, velocity))