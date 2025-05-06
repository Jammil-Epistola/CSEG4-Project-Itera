extends Control

func _ready():
	AudioPlayer.play_menu_music()

func _on_play_button_pressed() -> void:
	AudioPlayer.play_game_music() 
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_1.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/option_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
