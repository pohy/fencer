class_name Plank
extends StaticBody3D

signal fill_updated(fill_delta: float)

@export var fill_fetch_interval_s: float = 1.0

var fill_amount: float:
	get:
		return _current_fill

@onready var _sub_viewport: Viewport = $SubViewport
@onready var _brush: Sprite2D = $SubViewport/BrushSprite
@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _inactive_timer: Timer = $InactiveTimer

var _current_fill: float = 0.0
var _last_fill_fetch_at := -1.0

func _ready():
	_inactive_timer.timeout.connect(_update_fill_amount)

func _update_fill_amount():
	_last_fill_fetch_at = Time.get_ticks_msec()
	var fill = fetch_fill_amount()
	var fill_delta = fill - _current_fill
	_current_fill = fill
	fill_updated.emit(fill_delta)

# Returns normalized fill amount (in 0 -> 1 range)
func fetch_fill_amount() -> float:
	var image := _sub_viewport.get_texture().get_image()
	var w := image.get_width()
	var h := image.get_height()
	var full_fill := w * h
	var current_fill := 0.0
	for i in range(0, full_fill):
		var pos := Vector2i(i % w, i / w)
		var pixel := image.get_pixelv(pos)
		current_fill += pixel.a

	return current_fill / full_fill

# TODO: Accept modulation color
func stroke_brush(cursor_position_3d: Vector3, opacity: float = 1.0, rotation: float = 0.0, scale: float = 1.0):
	var viewport_mouse_pos = _calculate_viewport_mouse_position(cursor_position_3d)
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_brush.visible = true
	_brush.position = viewport_mouse_pos
	_brush.modulate.a = opacity
	_brush.rotation_degrees = rotation

	if Time.get_ticks_msec() - _last_fill_fetch_at > fill_fetch_interval_s * 1000:
		_update_fill_amount()
		_inactive_timer.stop()
	else:
		_inactive_timer.start()

func _calculate_viewport_mouse_position(mouse_position_3d: Vector3) -> Vector2:
	var mouse_pos_3d := global_transform.affine_inverse() * mouse_position_3d
	# convert the relative event position from 3D to 2D
	var mouse_pos_2d := Vector2(mouse_pos_3d.x, -mouse_pos_3d.y)

	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	mouse_pos_2d.x += _mesh.mesh.size.x / 2
	mouse_pos_2d.y += _mesh.mesh.size.y / 2
	# Then we need to convert it into the following range: 0 -> 1
	mouse_pos_2d.x = mouse_pos_2d.x / _mesh.mesh.size.x
	mouse_pos_2d.y = mouse_pos_2d.y / _mesh.mesh.size.y

	# Finally, we convert the position to the following range: 0 -> viewport.size
	mouse_pos_2d.x = mouse_pos_2d.x * _sub_viewport.size.x
	mouse_pos_2d.y = mouse_pos_2d.y * _sub_viewport.size.y
	# We need to do these conversions so the event's position is in the viewport's coordinate system.

	return mouse_pos_2d
