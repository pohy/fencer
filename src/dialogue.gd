extends Control

@export var paint_progress_tracker: PaintProgressTracker
@export var text_speed: float = 1.0
@export var visibility_lookahead: float = 1.8

@onready var _text_container: Container = $BackgroundRect/MarginContainer/ScrollContainer/VBoxContainer
@onready var _text_label: RichTextLabel = $BackgroundRect/MarginContainer/ScrollContainer/VBoxContainer/RichTextLabel

var _dialogue_lines: PackedStringArray = []
var _current_line_idx: int = -1
var _target_visible_ratio: float = 0.0

func _ready():
	assert(paint_progress_tracker is PaintProgressTracker, "PaintProgressTracker not found.")

	var file := FileAccess.open("res://assets/dialogue.txt", FileAccess.READ)
	var text := file.get_as_text()
	_dialogue_lines = text.split("\n")

	assert(_dialogue_lines.size() > 0, "Dialogue file is empty.")
	_text_label.text = ""

	print_debug("Dialogue line count: %s" % _dialogue_lines.size())
	print_debug("Character count: %s" % text.length())

	paint_progress_tracker.updated.connect(_on_paint_progress_updated)

func _process(delta):
	_text_label.visible_ratio = lerp(_text_label.visible_ratio, _target_visible_ratio * visibility_lookahead, text_speed * delta)

func _next_line():
	if _current_line_idx + 1 >= _dialogue_lines.size() - 1:
		return

	_current_line_idx += 1

	if _current_line_idx > 0:
		_text_label = _text_label.duplicate()
		_text_container.add_child(_text_label)
		_text_container.move_child(_text_label, 0)

	_text_label.text = _dialogue_lines[_current_line_idx]

func _on_paint_progress_updated(paint_progress: float):
	var next_line_at := 1.0 / _dialogue_lines.size() * (_current_line_idx + 1)

	var current_line_progress := 1.0 - (next_line_at - paint_progress) * _dialogue_lines.size()
	_target_visible_ratio = current_line_progress

	if paint_progress >= next_line_at:
		_next_line()
		_text_label.visible_ratio = 0
		_target_visible_ratio = 0
	