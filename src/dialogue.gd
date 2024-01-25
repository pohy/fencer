extends Control

@export var paint_progress_tracker: PaintProgressTracker
@export var text_speed: float = 1.0
@export var visibility_lookahead: float = 1.8

@onready var _text_label: RichTextLabel = $BackgroundRect/MarginContainer/RichTextLabel
@onready var _line_progress_bar: ProgressBar = $BackgroundRect/LineProgressBar

var _dialogue_lines: PackedStringArray = []
var _current_line_idx: int = -1
var _target_visible_ratio: float = 0.0

func _ready():
	assert(paint_progress_tracker is PaintProgressTracker, "PaintProgressTracker not found.")

	var file := FileAccess.open("res://assets/dialogue.txt", FileAccess.READ)
	var text := file.get_as_text()
	_dialogue_lines = text.split("\n")

	_line_progress_bar.value = 0

	assert(_dialogue_lines.size() > 0, "Dialogue file is empty.")
	_text_label.text = ""
	# _next_line()

	print_debug("Dialogue line count: %s" % _dialogue_lines.size())
	print_debug("Character count: %s" % text.length())

	paint_progress_tracker.updated.connect(_on_paint_progress_updated)

func _process(delta):
	_text_label.visible_ratio = lerp(_text_label.visible_ratio, _target_visible_ratio * visibility_lookahead, text_speed * delta)
	_line_progress_bar.value = lerp(_line_progress_bar.value, _target_visible_ratio, text_speed * delta)

func _next_line():
	if _current_line_idx + 1 >= _dialogue_lines.size() - 1:
		return

	_current_line_idx += 1
	_text_label.text = _dialogue_lines[_current_line_idx]

	print_debug("📜Advancing to next dialogue line: %s" % _text_label.text)

func _on_paint_progress_updated(paint_progress: float):
	var next_line_at := 1.0 / _dialogue_lines.size() * (_current_line_idx + 1)
	# print_debug("♻️Next dialogue line at: %s/%s" % [paint_progress, next_line_at])

	var current_line_progress := 1.0 - (next_line_at - paint_progress) * _dialogue_lines.size()
	# print_debug("📏Current dialogue line progress: %s" % current_line_progress)
	# current_line_progress *= visibility_lookahead # Leave time for the whole line to be displayed
	# current_line_progress = clamp(current_line_progress, 0.0, 1.0)
	# print_debug("📐Current dialogue line clamped: %s" % current_line_progress)
	_target_visible_ratio = current_line_progress

	if paint_progress >= next_line_at:
		_next_line()
		_text_label.visible_ratio = 0
		_target_visible_ratio = 0
	