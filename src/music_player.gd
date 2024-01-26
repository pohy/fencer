extends AudioStreamPlayer

@export var paint_progress_tracker: PaintProgressTracker

var _music_bus_idx := 2
var _high_pass_filter_effect_idx := 0
var _low_pass_filter_effect_idx := 1

var _high_pass_filter: AudioEffectHighPassFilter
var _low_pass_filter: AudioEffectLowPassFilter

var _high_pass_initial_cutoff_hz: float
var _low_pass_initial_cutoff_hz: float

var _high_pass_target_cutoff_hz: float
var _low_pass_target_cutoff_hz: float

func _ready():
	assert(paint_progress_tracker is PaintProgressTracker, "paint_progress_tracker not set")

	# _music_bus_idx = AudioServer.get_bus_index("music")
	print_debug("music bus idx: " + str(_music_bus_idx))
	_high_pass_filter = AudioServer.get_bus_effect(_music_bus_idx, _high_pass_filter_effect_idx)
	_low_pass_filter = AudioServer.get_bus_effect(_music_bus_idx, _low_pass_filter_effect_idx)

	_high_pass_initial_cutoff_hz = _high_pass_filter.cutoff_hz
	_low_pass_initial_cutoff_hz = _low_pass_filter.cutoff_hz
	_high_pass_target_cutoff_hz = _high_pass_initial_cutoff_hz
	_low_pass_target_cutoff_hz = _low_pass_initial_cutoff_hz

	paint_progress_tracker.updated.connect(_on_paint_progress_updated)

func _on_paint_progress_updated(paint_progress: float):

	_high_pass_target_cutoff_hz = _high_pass_initial_cutoff_hz - (_high_pass_initial_cutoff_hz) * min(1, paint_progress * 10)
	_high_pass_filter.cutoff_hz = _high_pass_target_cutoff_hz
	if _high_pass_target_cutoff_hz <= 1:
		AudioServer.set_bus_effect_enabled(_music_bus_idx, _high_pass_filter_effect_idx, false)

	_low_pass_target_cutoff_hz = _low_pass_initial_cutoff_hz + (20500 - _low_pass_initial_cutoff_hz) * min(1, paint_progress * 5)
	_low_pass_filter.cutoff_hz = _low_pass_target_cutoff_hz
	if _low_pass_filter.cutoff_hz >= 20500:
		AudioServer.set_bus_effect_enabled(_music_bus_idx, _low_pass_filter_effect_idx, false)
