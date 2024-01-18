extends MeshInstance3D

@export var brush_sprite: Sprite2D
@export var color_rect: ColorRect

@onready var mouse: MouseInpt = $Mouse
@onready var debug_sphere: MeshInstance3D = $DebugSphere
@onready var sub_viewport: SubViewport = $SubViewport
@onready var static_body: StaticBody3D = $StaticBody3D

var material: StandardMaterial3D

func _ready():
	debug_sphere.scale = Vector3.ONE * 10

	material = material_override as StandardMaterial3D
	assert(material is StandardMaterial3D, "Material must be a StandardMaterial3D")

	assert(color_rect is ColorRect, "ColorRect must be a ColorRect")

func _process(delta):
	if not mouse.is_moving:
		return

	var camera := get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	# print_debug("🐁 Mouse position: %s" % mouse_pos)
	var space_state = get_world_3d().direct_space_state
	var origin := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)
	var target := origin + direction * 100
	var ray := PhysicsRayQueryParameters3D.create(origin, target)
	# print_debug("🌍 Ray origin: %s, Ray direction: %s" % [origin, direction])
	debug_sphere.global_position = target
	var result := space_state.intersect_ray(ray)
	if result:
		var viewport_mouse_pos = _calculate_viewport_mouse_position(result.position)
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		brush_sprite.position = viewport_mouse_pos # TODO: Why it needs to be halved, wtf? Still not working though, still drifting :); Because we would need to calculate UV coordinates

func _calculate_viewport_mouse_position(mouse_position_3d: Vector3) -> Vector2:
	var mouse_pos_3d := static_body.global_transform.affine_inverse() * mouse_position_3d
	# convert the relative event position from 3D to 2D
	var mouse_pos_2d := Vector2(mouse_pos_3d.x, -mouse_pos_3d.y)

	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	mouse_pos_2d.x += mesh.size.x / 2
	mouse_pos_2d.y += mesh.size.y / 2
	# print_debug("Mouse position 0 -> mesh.size: %s" % mouse_pos_2d)
	# Then we need to convert it into the following range: 0 -> 1
	mouse_pos_2d.x = mouse_pos_2d.x / mesh.size.x
	mouse_pos_2d.y = mouse_pos_2d.y / mesh.size.y
	# print_debug("Mouse position 0 -> 1: %s" % mouse_pos_2d)

	# Finally, we convert the position to the following range: 0 -> viewport.size
	mouse_pos_2d.x = mouse_pos_2d.x * sub_viewport.size.x
	mouse_pos_2d.y = mouse_pos_2d.y * sub_viewport.size.y
	# print_debug("Mouse position 0 -> viewport.size: %s" % mouse_pos_2d)
	# We need to do these conversions so the event's position is in the viewport's coordinate system.

	return mouse_pos_2d
