extends Control

const game_path = "res://scenes/game_level.tscn"

@onready var auth_overlay = %auth_overlay
@onready var login_form = %login_form
@onready var register_form = %register_form
@onready var login_button = $login_button # To jest blisko, może zostać $
@onready var close_button = %close_button

func _ready() -> void:
	# 1. Obsługa fokusu (jeśli przycisk istnieje)
	if has_node("menu_container/new_game_button"):
		$menu_container/new_game_button.grab_focus()
	
	# 2. Animacja tytułu (sprawdzamy czy istnieje, żeby nie było błędu)
	if has_node("title"):
		var title_node = $title
		title_node.pivot_offset = title_node.size / 2
		var tween = create_tween().set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(title_node, "scale", Vector2(1.1, 1.1), 1.5)
		tween.tween_property(title_node, "scale", Vector2(1.0, 1.0), 1.5)
	
	# 3. Konfiguracja Overlay
	auth_overlay.visible = false
	
	# 4. Podpinanie sygnałów
	login_button.pressed.connect(_on_open_login_pressed)
	close_button.pressed.connect(_on_close_auth_pressed)
	
	# 5. Przyciski wewnątrz formularzy
	# Używam nazw widocznych na Twoim screenie image_e4c3e0.png
	var go_reg_btn = login_form.get_node("go_to_register_button")
	go_reg_btn.pressed.connect(_on_go_to_register_pressed)
	
	var back_login_btn = register_form.get_node("back_to_login_button")
	back_login_btn.pressed.connect(_on_back_to_login_pressed)

# --- FUNKCJE OBSŁUGI OKIENKA ---

func _on_open_login_pressed():
	auth_overlay.visible = true
	login_form.visible = true
	register_form.visible = false 

func _on_go_to_register_pressed():
	login_form.visible = false
	register_form.visible = true

func _on_back_to_login_pressed():
	register_form.visible = false
	login_form.visible = true
	
func _on_close_auth_pressed():
	auth_overlay.visible = false

# --- POZOSTAŁE FUNKCJE MENU ---

func _process(_delta: float) -> void: # Podłoga przed delta ucisza warning
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
