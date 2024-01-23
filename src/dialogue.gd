extends Control

@export var paint_progress_tracker: PaintProgressTracker

@onready var _text_label: RichTextLabel = $BackgroundRect/MarginContainer/RichTextLabel

var _dialogue_lines: PackedStringArray = []
var _current_line_idx: int = -1

func _ready():
	assert(paint_progress_tracker is PaintProgressTracker, "PaintProgressTracker not found.")

	var file := FileAccess.open("res://assets/dialogue.txt", FileAccess.READ)
	var text := file.get_as_text()
	_dialogue_lines = text.split("\n")

	assert(_dialogue_lines.size() > 0, "Dialogue file is empty.")
	_text_label.text = ""
	# next_line()

	print_debug("Dialogue line count: %s" % _dialogue_lines.size())

	paint_progress_tracker.updated.connect(_on_paint_progress_updated)

func next_line():
	if _current_line_idx + 1 >= _dialogue_lines.size() - 1:
		return

	_current_line_idx += 1
	_text_label.text = _dialogue_lines[_current_line_idx]

func _on_paint_progress_updated(progress: float):
	if _current_line_idx < 0:
		print_debug("Initiating dialogue")
		next_line()
		return

	var next_line_at := 1.0 / _dialogue_lines.size() * (_current_line_idx + 1)
	print_debug("Next dialogue line at: %s/%s" % [progress, next_line_at])
	if progress >= next_line_at:
		next_line()