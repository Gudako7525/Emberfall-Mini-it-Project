extends Control

func _on_start_pressed() -> void:
	print("start_pressed")
	get_tree().change_scene_to_file("res://ember_fall2.tscn")

func _on_settings_pressed() -> void:
	print("exit_pressed")
	get_tree().quit()

func _on_exit_pressed() -> void:
	print("settings pressed")
