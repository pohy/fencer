class_name PaintProgressTracker
extends Node

signal updated(progress: float)

var paint_fill_progress: float:
    get:
        return _fill_sum / _planks.size()

var _fill_sum: float = 0.0
var _planks: Array[Plank] = []

func _ready():
    var maybe_planks = get_tree().get_nodes_in_group("plank")
    for plank in maybe_planks:
        if not plank is Plank:
            continue
        
        _planks.append(plank)
        plank.fill_updated.connect(_on_fill_updated)


func _on_fill_updated(fill_delta: float):
    _fill_sum += fill_delta
    updated.emit(paint_fill_progress)
