extends Control
const game_path = "res://scenes/game_level.tscn"
const menu_path = "res://scenes/main_menu.tscn"

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file(game_path)


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(menu_path)
