extends Control



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TestLevel.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/option_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
