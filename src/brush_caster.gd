extends Node3D

@export var speed: float = 1.0
@export var depletion_rate: float = 1.0
@export var apply_interval_s: float = 0.1
@export var apply_velocity_multiplier: float = 1.0
@export var tilt_amount: float = 10.0

@onready var _mouse: MouseInpt = $Mouse
@onready var _brush_model: Node3D = $BrushModel
@onready var _brush_fill_progress: ProgressBar = $BrushModel/SubViewport/ProgressBar


var _target_position: Vector2 = Vector2.ZERO
var _current_position: Vector2 = Vector2.ZERO
var _paint_fill: float = 1.0
var _distance_travelled: float = 0.0
var _since_last_application_s: float = 0.0
var _brush_initial_basis: Basis = Basis.IDENTITY

func _ready():
	_brush_initial_basis = Basis(_brush_model.basis)

func _process(delta):
	_target_position = _mouse.position
	var move_delta = _current_position - _target_position
	var velocity = move_delta.length()
	_current_position -= move_delta
	_distance_travelled += velocity

	_apply_tilt(delta, move_delta, velocity)
	_update_application_timers(delta, velocity)

	# TODO: Refill from a coloured bucket
	if _mouse.left_released:
		_paint_fill = 1.0

	_apply_brush_stroke(delta, move_delta, velocity)

	_brush_fill_progress.value = _paint_fill

func _apply_brush_stroke(delta: float, move_delta: Vector2, velocity: float):
	var camera := get_viewport().get_camera_3d()
	var from := camera.project_ray_origin(_current_position)
	var to := from + camera.project_ray_normal(_current_position) * 1000
	var query_params := PhysicsRayQueryParameters3D.create(from, to)
	var query := get_world_3d().direct_space_state.intersect_ray(query_params)

	var is_plank_hit = query.size() > 0 and query.collider is Plank
	if is_plank_hit:
		_brush_model.global_position = query.position + query.normal * 0.1
		if _mouse.left and _since_last_application_s <= 0.0 and velocity > 0.0:
			var paint_used = depletion_rate * velocity * apply_velocity_multiplier * delta
			# TODO: Pass current paint color
			var dir_rotation = rad_to_deg(atan2(move_delta.y, move_delta.x)) - 90
			query.collider.stroke_brush(query, _paint_fill * 0.1, dir_rotation)
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