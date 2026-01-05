extends Camera2D

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("camera"):
		set_zoom(Vector2(0.5, 0.5))
		return
	if event.is_action_released("camera"):
		set_zoom(Vector2(1,1))
		return
