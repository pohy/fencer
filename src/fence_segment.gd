class_name FenceSegment
extends Area3D

enum MonitorPosition {
    LEFT, RIGHT
}

var is_active = false
var left_fence: FenceSegment:
    get: return _left_fence
var right_fence: FenceSegment:
    get: return _right_fence
var camera_position: Node3D:
    get: return _camera_position

@onready var _left_fence_monitor: Area3D = $LeftFenceMonitor
@onready var _right_fence_monitor: Area3D = $RightFenceMonitor
@onready var _camera_position: Node3D = $CameraPosition

var _left_fence: FenceSegment = null
var _right_fence: FenceSegment = null

func _ready():
    _left_fence_monitor.area_entered.connect(_on_fence_monitor(MonitorPosition.LEFT))
    _right_fence_monitor.area_entered.connect(_on_fence_monitor(MonitorPosition.RIGHT))

func _on_fence_monitor(monitor_position: MonitorPosition):
    # TODO: Validate that both left and right fences have been found
    return func(area: Area3D):
        if area.is_in_group("fence") and area is FenceSegment and area != self:
            match monitor_position:
                MonitorPosition.LEFT:
                    _left_fence = area
                MonitorPosition.RIGHT:
                    _right_fence = area
                _:
                    assert(false, "Invalid monitor_position: %s" % monitor_position)
