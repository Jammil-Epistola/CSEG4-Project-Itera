extends Control

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_controls_button_pressed() -> void:
	$SettingsTabContainer.current_tab = 0


func _on_audio_button_pressed() -> void:
	$SettingsTabContainer.current_tab = 1


func _on_others_pressed() -> void:
	$SettingsTabContainer.current_tab = 2
