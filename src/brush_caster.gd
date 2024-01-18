extends Node3D

@onready var _mouse: MouseInpt = $Mouse
@onready var _debug_sphere: MeshInstance3D = $DebugSphere


func _process(delta):
	if not _mouse.is_moving:
		return

	var camera := get_viewport().get_camera_3d()
	var from := camera.project_ray_origin(_mouse.position)
	var to := from + camera.project_ray_normal(_mouse.position) * 1000
	var query_params := PhysicsRayQueryParameters3D.create(from, to)
	var query := get_world_3d().direct_space_state.intersect_ray(query_params)

	var plank_hit = query.size() > 0 and query.collider is Plank
	_debug_sphere.visible = plank_hit
	if plank_hit:
		_debug_sphere.position = query.position
		if _mouse.left:
			query.collider.update_brush(query)
