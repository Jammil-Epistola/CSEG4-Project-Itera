extends Area3D

const FILE_BEGIN = "res://Scenes/Levels/Rooms 2-5/Level_"

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var current_scene_file = get_tree().current_scene.scene_file_path
		var current_level_number = current_scene_file.get_basename().get_file().to_int()
		var next_level_number = current_level_number + 1
		
		print("Loading Level:", next_level_number)
		
		var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
		call_deferred("load_next_level", next_level_path)  # Defer scene change to avoid issues

func load_next_level(next_level_path: String) -> void:
	get_tree().change_scene_to_file(next_level_path)  # Change to the next level
