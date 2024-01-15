extends MeshInstance3D

@export var brush_sprite: Sprite2D

@onready var mouse: MouseInpt = $Mouse

func _process(delta):
	# if mouse.pressed:
	# var mouse_pos_3d := get_viewport().get_camera()
	# var mouse_pos_2d := Vector2(mouse_pos_3d.x, mouse_pos_3d.y)
	brush_sprite.position += mouse.delta
