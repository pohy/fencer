extends Control

@export var fence_segment_tracker: FenceSegmentTracker
@export var direction: FenceSegment.MonitorPosition
@export var trigger_delay_s: float = 1.0
@export var arrow_travel_distance: float = 100.0

@onready var _trigger_timer: Timer = $TriggerTimer
@onready var _texture_rect: TextureRect = $TextureRect

var _arrow_initial_pos: Vector2 = Vector2.ZERO

func _ready():
    assert(fence_segment_tracker is FenceSegmentTracker, "FenceSegmentTracker not set")

    _arrow_initial_pos = _texture_rect.position
    if direction == FenceSegment.MonitorPosition.LEFT:
        _texture_rect.flip_h = true

    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    _trigger_timer.timeout.connect(_on_trigger_timeout)

func _process(delta):
    var opacity := 1.0 - _trigger_timer.time_left / _trigger_timer.wait_time
    if _trigger_timer.is_stopped():
        opacity = 0.0

    modulate.a = 1.3 * opacity * opacity
    var travel_sign := -1 if direction == FenceSegment.MonitorPosition.LEFT else 1
    _texture_rect.position.x = _arrow_initial_pos.x + arrow_travel_distance * opacity * travel_sign

func _on_trigger_timeout():
    fence_segment_tracker.activate_neighbouring_segment(direction)

func _on_mouse_entered():
    # print("Mouse entered %s" % direction)
    _trigger_timer.start(trigger_delay_s)

func _on_mouse_exited():
    _trigger_timer.stop()
