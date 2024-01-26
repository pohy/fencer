extends Label3D

func _ready():
    # var initial_pos = position
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position", position - Vector3.UP * 1.5, 7.0).set_trans(Tween.TRANS_QUART)
    tween.tween_property(self, "position", position - Vector3.UP * 5, 3.0).set_trans(Tween.TRANS_EXPO)
    tween.tween_callback(queue_free)
