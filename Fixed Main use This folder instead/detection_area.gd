extends Area2D

@export var battle_scene_path : String = "res://battlescene.tscn"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file(battle_scene_path)
