extends Node3D

@export var speed: float = 1.0

@onready var _mouse: MouseInpt = $Mouse
@onready var _debug_sphere: MeshInstance3D = $DebugSphere
@onready var _brush_mesh: Node3D = $Brush


var _target_position: Vector2 = Vector2.ZERO
var _current_position: Vector2 = Vector2.ZERO

func _process(delta):
	# if not _mouse.is_moving:
	# 	return

	_target_position = _mouse.position
	_current_position = lerp(_current_position, _target_position, delta * speed)

	if (_current_position - _target_position).length_squared() < 0.01:
		return

	var camera := get_viewport().get_camera_3d()
	var from := camera.project_ray_origin(_current_position)
	var to := from + camera.project_ray_normal(_current_position) * 1000
	var query_params := PhysicsRayQueryParameters3D.create(from, to)
	var query := get_world_3d().direct_space_state.intersect_ray(query_params)

	var is_plank_hit = query.size() > 0 and query.collider is Plank
	# _debug_sphere.visible = plank_hit
	if is_plank_hit:
		# _debug_sphere.position = query.position + query.normal * 0.1
		_brush_mesh.global_position = query.position + query.normal * 0.1
		if _mouse.left:
			query.collider.update_brush(query)
