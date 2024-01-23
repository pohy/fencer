extends Control

@onready var _text_label: RichTextLabel = $BackgroundRect/MarginContainer/RichTextLabel
@onready var _timer: Timer = $Timer

var _dialogue_lines: PackedStringArray = []
var _current_line_idx: int = -1

func _ready():
    var file := FileAccess.open("res://assets/dialogue.txt", FileAccess.READ)
    var text := file.get_as_text()
    _dialogue_lines = text.split("\n")

    assert(_dialogue_lines.size() > 0, "Dialogue file is empty.")
    next_line()

    # TODO: Progress through means other than a timer :^)
    _timer.timeout.connect(func(): next_line())

func next_line():
    if _current_line_idx + 1 >= _dialogue_lines.size() - 1:
        return

    _current_line_idx += 1
    _text_label.text = _dialogue_lines[_current_line_idx]
