extends Node3D

@export var speed: float = 1.0
@export var depletion_rate: float = 1.0
@export var apply_interval_s: float = 0.1

@onready var _mouse: MouseInpt = $Mouse
@onready var _debug_sphere: MeshInstance3D = $DebugSphere
@onready var _brush_model: Node3D = $BrushModel


var _target_position: Vector2 = Vector2.ZERO
var _current_position: Vector2 = Vector2.ZERO
var _paint_fill: float = 1.0
var _distance_travelled: float = 0.0
var _since_last_application_s: float = 0.0

func _process(delta):
	# if not _mouse.is_moving:
	# 	return

	_target_position = _mouse.position
	# var move_delta = _current_position - lerp(_current_position, _target_position, delta * speed)
	var move_delta = _current_position - _target_position
	var velocity = move_delta.length()
	_current_position -= move_delta
	_distance_travelled += velocity

	# _paint_fill = sin(_distance_travelled * depletion_rate) * 0.5 + 0.5
	print_debug("Move delta: %s" % velocity)
	# print_debug("Paint fill: %s" % _paint_fill)

	# if (_current_position - _target_position).length_squared() < 0.01:
	# 	return

	if _mouse.left:
		_since_last_application_s += delta
	else:
		_since_last_application_s = 0.0
	var current_apply_interval_s = apply_interval_s / max(1, velocity)
	print_debug("apply interval: %s" % current_apply_interval_s)
	if _since_last_application_s > current_apply_interval_s:
		_since_last_application_s = 0.0

	if _mouse.left_released:
		_paint_fill = 1.0

	var camera := get_viewport().get_camera_3d()
	var from := camera.project_ray_origin(_current_position)
	var to := from + camera.project_ray_normal(_current_position) * 1000
	var query_params := PhysicsRayQueryParameters3D.create(from, to)
	var query := get_world_3d().direct_space_state.intersect_ray(query_params)

	var is_plank_hit = query.size() > 0 and query.collider is Plank
	# _debug_sphere.visible = plank_hit
	if is_plank_hit:
		# _debug_sphere.position = query.position + query.normal * 0.1
		_brush_model.global_position = query.position + query.normal * 0.1
		if _mouse.left and _since_last_application_s <= 0.0 and velocity > 0.0:
			query.collider.stroke_brush(query, _paint_fill * 0.1)
			_paint_fill = max(0.0, _paint_fill - depletion_rate * velocity * delta)
