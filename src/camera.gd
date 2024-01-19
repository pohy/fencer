extends Camera3D

@export var sensitivity: Vector2 = Vector2.ONE

@onready var _mouse: MouseInpt = $Mouse

var _initial_rotation: Vector3 = Vector3.ZERO

func _ready():
	_initial_rotation = global_rotation

func _process(delta):
	var rotation_offset := _mouse.from_center * sensitivity
	global_rotation.x = _initial_rotation.x - deg_to_rad(rotation_offset.y)
	global_rotation.y = _initial_rotation.y - deg_to_rad(rotation_offset.x)
