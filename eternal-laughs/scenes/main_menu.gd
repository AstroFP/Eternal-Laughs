extends Control

const game_path = "res://scenes/game_level.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$menu_container/new_game_button.grab_focus()
	var title_node = $title
	title_node.pivot_offset = title_node.size / 2
	var tween = create_tween().set_loops() # set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(title_node, "scale", Vector2(1.1, 1.1), 1.5)
	tween.tween_property(title_node, "scale", Vector2(1.0, 1.0), 1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file(game_path)


func _on_load_game_button_pressed() -> void:
	print("Saved games here (someday)")


func _on_options_button_pressed() -> void:
	print("Options here (someday)")


func _on_credits_button_pressed() -> void:
	print("Informations about game's creators (someday)")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
