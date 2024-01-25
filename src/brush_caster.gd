class_name BrushCaster
extends Node3D

@export var brush_speed: float = 1.0
@export var depletion_rate: float = 1.0
@export var apply_interval_s: float = 0.1
@export var apply_velocity_multiplier: float = 1.0
@export var tilt_amount: float = 10.0

var velocity: float = 0.0
var is_painting: bool:
	get:
		return _mouse.left and _current_plank != null

@onready var _mouse: MouseInpt = $Mouse
@onready var _brush_model: Node3D = $BrushModel
@onready var _brush_fill_progress: ProgressBar = $BrushModel/SubViewport/ProgressBar

var _target_cursor_position: Vector2 = Vector2.ZERO
var _current_cursor_position: Vector2 = Vector2.ZERO
var _paint_fill: float = 1.0
var _distance_travelled: float = 0.0
var _since_last_application_s: float = 0.0
var _mouse_position_3d: Vector3 = Vector3.ZERO
var _current_plank: Plank = null
var _target_brush_position: Vector3 = Vector3.ZERO
var _camera: Camera = null

func _ready():
	_camera = get_viewport().get_camera_3d()
	assert(_camera is Camera, "Camera not found")

func _process(delta):
	_target_cursor_position = _mouse.position
	var move_delta := _current_cursor_position - _target_cursor_position
	velocity = move_delta.length()
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
	var ray_origin := camera.project_ray_origin(_current_cursor_position)
	var ray_direction := camera.project_ray_normal(_current_cursor_position)
	var to := ray_origin + ray_direction * 1000
	var query_params := PhysicsRayQueryParameters3D.create(ray_origin, to)
	var query := get_world_3d().direct_space_state.intersect_ray(query_params)

	var is_plank_hit = query.size() > 0 and query.collider is Plank and query.collider.is_active

	if is_plank_hit:
		_mouse_position_3d = query.position
		_current_plank = query.collider
	else:
		# TODO: The brush lags behind the cursor heavily, but good enough for now :)
		var prev_mouse_pos = _current_cursor_position - _mouse.delta
		var world_space_cursor_delta = _camera.project_ray_normal(_current_cursor_position) - _camera.project_ray_normal(prev_mouse_pos)
		_mouse_position_3d += world_space_cursor_delta

	if not is_plank_hit and not _mouse.left:
		_current_plank = null

	if _current_plank != null:
		var distance_from_plank = 0.12 if _mouse.left else 0.23
		_target_brush_position = _mouse_position_3d - ray_direction * distance_from_plank
	else:
		_target_brush_position = ray_origin + ray_direction

	_brush_model.global_position = lerp(_brush_model.global_position, _target_brush_position, brush_speed * delta)
	

func _apply_brush_stroke(delta: float, move_delta: Vector2, velocity: float):
	if _current_plank == null:
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
	var camera_basis = _camera.global_transform.basis
	var tilt_amount_rad = deg_to_rad(min(tilt_amount, velocity * (10 if _mouse.left else 2)))

	var rotation_towards_fence_deg := 160
	if _current_plank != null:
		rotation_towards_fence_deg = 90 if _mouse.left else 100

	var target_basis = camera_basis \
		.rotated(camera_basis.z, move_delta.normalized().x * tilt_amount_rad) \
		.rotated(camera_basis.x, -move_delta.normalized().y * tilt_amount_rad) \
		.rotated(camera_basis.x, deg_to_rad(rotation_towards_fence_deg))
	_brush_model.basis = _brush_model.basis.slerp(target_basis, delta * max(10, velocity))