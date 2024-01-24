extends Node

@export var initial_segment: FenceSegment

var _active_segment: FenceSegment = null
var _segments: Array[FenceSegment] = []
var _camera: Camera

func _ready():
	_camera = get_viewport().get_camera_3d()
	assert(_camera is Camera, "Camera not found")

	assert(initial_segment is FenceSegment, "Initial segment not set")
	_activate_segment(initial_segment)

	var segments = get_tree().get_nodes_in_group("fence_segment") as Array[FenceSegment]
	for _segment in segments:
		assert(_segment is FenceSegment, "Node in fence_segment group is not a FenceSegment")
		_segments.append(_segment)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == Key.KEY_LEFT and _active_segment.left_fence is FenceSegment:
			_activate_segment(_active_segment.left_fence)
		if event.keycode == Key.KEY_RIGHT and _active_segment.right_fence is FenceSegment:
			_activate_segment(_active_segment.right_fence)

func _activate_segment(segment: FenceSegment):
	if _active_segment is FenceSegment:
		_active_segment.is_active = false

	_active_segment = segment
	_active_segment.is_active = true
	_camera.target_position = _active_segment.camera_position
