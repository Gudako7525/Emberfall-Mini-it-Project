class_name SceneTrigger extends CollisionShape2D

@export var connected_scene : String
var scene_folder = "res://"


func _on_body_entered(body: Node2D) -> void:
	var full_path = scene_folder + connected_scene + ".tscn"
	var scene_tree = get_tree()
	get_tree().change_scene_to_file.call_deferred(full_path)
