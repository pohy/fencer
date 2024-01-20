extends Camera3D

@export var sensitivity: Vector2 = Vector2.ONE
@export var sensitivity_zoomed_multiplier: float = 2.0
@export var zoom_on_paint: float = 10.0
@export var zoom_speed: float = 10.0

@onready var _mouse: MouseInpt = $Mouse
@onready var _sensitivity: Vector2 = sensitivity

var _initial_rotation: Vector3 = Vector3.ZERO
var _initial_fov: float = 0.0

func _ready():
	_initial_rotation = global_rotation
	_initial_fov = fov

func _process(delta):
	var is_zoomed := _mouse.left

	var target_sensitivity = sensitivity * sensitivity_zoomed_multiplier if is_zoomed else sensitivity
	_sensitivity = lerp(_sensitivity, target_sensitivity, zoom_speed * delta)

	var rotation_offset := _mouse.from_center * _sensitivity
	global_rotation.x = _initial_rotation.x - deg_to_rad(rotation_offset.y)
	global_rotation.y = _initial_rotation.y - deg_to_rad(rotation_offset.x)
	# var origin = project_ray_origin(_mouse.position)
	# var direction = project_ray_normal(_mouse.position)
	# look_at(origin + direction * 1000, Vector3.UP)

	var target_fov = _initial_fov - zoom_on_paint if is_zoomed else _initial_fov
	fov = lerp(fov, target_fov, zoom_speed * delta)
