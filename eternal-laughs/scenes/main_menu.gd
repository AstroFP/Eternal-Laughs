extends Control

const game_path = "res://scenes/game_level.tscn"

# --- ZMIENNE UI ---
@onready var auth_overlay = %auth_overlay
@onready var login_form = %login_form
@onready var register_form = %register_form

@onready var login_button = %login_button 
@onready var close_button = %close_button
@onready var user_label = %user_label 

@onready var shop_button = $top_bar/shop_button
@onready var shop = %shop

# HTTP Request
@onready var http_sender = $http_request
@onready var loading_icon = $loading_icon
var is_request_in_progress := false

# Zmienne stanu
var current_request_type = ""

# --- FUNKCJE POMOCNICZE ---
func show_loading(is_register=false):
	is_request_in_progress = true
	loading_icon.visible = true
	login_button.disabled = true
	if is_register:
		loading_icon.position = Vector2(255, 150)
	else:
		loading_icon.position = Vector2(255, 133) 

func hide_loading():
	is_request_in_progress = false
	loading_icon.visible = false
	login_button.disabled = false

func clear_error_labels():
	if has_node("%login_error_label"):
		%login_error_label.text = ""
	if has_node("%register_error_label"):
		%register_error_label.text = ""

func update_ui_after_login():
	if Global.is_logged_in():  # <- WYWOŁANIE FUNKCJI
		login_button.text = "LOGOUT"
		user_label.text = "Witaj " + Global.username + "!"
		user_label.visible = true
		$menu_container/new_game_button.disabled = false
		$menu_container/load_game_button.disabled = false
	else:
		login_button.text = "LOGIN"
		user_label.visible = false
		$menu_container/new_game_button.disabled = true
		$menu_container/load_game_button.disabled = true

# --- READY ---
func _ready() -> void:
	loading_icon.size = Vector2(1, 1)
	loading_icon.pivot_offset = loading_icon.size / 2

	login_button.grab_focus()
	
	# Ukrycie shop button
	shop_button.visible = false
	shop_button.pressed.connect(_on_shop_button_pressed)

	# Animacja tytułu
	if has_node("title"):
		var title_node = $title
		title_node.pivot_offset = title_node.size / 2
		var tween = create_tween().set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(title_node, "scale", Vector2(1.1, 1.1), 1.5)
		tween.tween_property(title_node, "scale", Vector2(1.0, 1.0), 1.5)

	# Overlay ukryty na start
	auth_overlay.visible = false

	# Ustaw UI zgodnie ze stanem globalnym
	update_ui_after_login()

	# Podpinanie sygnałów
	login_button.pressed.connect(_on_open_login_pressed)
	close_button.pressed.connect(_on_close_auth_pressed)

	login_form.get_node("go_to_register_button").pressed.connect(_on_go_to_register_pressed)
	register_form.get_node("back_to_login_button").pressed.connect(_on_back_to_login_pressed)

	login_form.get_node("submit_login_button").pressed.connect(_on_submit_login_pressed)
	register_form.get_node("register_button").pressed.connect(_on_submit_register_pressed)

	http_sender.request_completed.connect(_on_server_responded)

# --- LOGOWANIE ---
func _on_submit_login_pressed():
	
	if is_request_in_progress:
		return
	var email = %login_email_input.text
	var password = %login_pwd_input.text
	
	if email == "" or password == "":
		print("Błąd: Puste pola!")
		return

	var data_to_send = {"email": email, "password": password}
	current_request_type = "LOGIN"
	show_loading(false)
	send_post_request("https://eternal-laughs-1.onrender.com/api/auth/login/", data_to_send)

# --- REJESTRACJA ---
func _on_submit_register_pressed():
	if is_request_in_progress:
		return
	var username = %reg_username_input.text
	var email = %reg_email_input.text
	var pass1 = %reg_pwd_input.text
	var pass2 = %reg_pwd_repeat_input.text
	
	if username == "" or email == "" or pass1 == "":
		print("Błąd: Wypełnij wszystkie pola")
		return

	if pass1 != pass2:
		if has_node("%register_error_label"):
			%register_error_label.text = "Hasła nie są takie same!"
			%register_error_label.modulate = Color(1, 0, 0)
		return

	var data_to_send = {
		"username": username,
		"email": email,
		"password": pass1,
		"password2": pass2
	}
	current_request_type = "REGISTER"
	show_loading(true)
	send_post_request("https://eternal-laughs-1.onrender.com/api/auth/register/", data_to_send)

# --- HTTP HELPER ---
func send_post_request(url: String, data: Dictionary):
	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(data)
	var error = http_sender.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("Błąd połączenia z siecią! Kod błędu: ", error)

# --- ODBIÓR ODPOWIEDZI ---
func _on_server_responded(_result, response_code, _headers, body):
	hide_loading()
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	var response_data = {}
	if parse_result == OK:
		response_data = json.get_data()

	if response_code in [200, 201]:
		clear_error_labels()
		
		if current_request_type == "LOGIN":
			Global.access_token = str(response_data.get("access", ""))
			Global.refresh_token = str(response_data.get("refresh", ""))
			Global.username = str(response_data.get("username", response_data.get("email", "Graczu")))
			print("Zalogowano jako:", Global.username)
			print("Access token:", Global.access_token)


			

			auth_overlay.visible = false
			update_ui_after_login()
			shop_button.visible = true
		elif current_request_type == "REGISTER":
			_on_back_to_login_pressed()
			if has_node("%login_error_label"):
				%login_error_label.text = "Konto utworzone! Kliknij link w e-mailu."
				%login_error_label.modulate = Color(0, 1, 0)

	elif response_code >= 400:
		var error_message = "Wystąpił nieznany błąd."
		if response_data.has("non_field_errors"):
			error_message = "\n".join(response_data["non_field_errors"]) if response_data["non_field_errors"] is Array else str(response_data["non_field_errors"])
		elif response_data.has("detail"): error_message = response_data["detail"]
		elif response_data.has("password"): error_message = "Hasło: " + str(response_data["password"][0])
		elif response_data.has("email"): error_message = "Email: " + str(response_data["email"][0])
		elif response_data.has("username"): error_message = "Login: " + str(response_data["username"][0])
		
		if current_request_type == "LOGIN" and has_node("%login_error_label"):
			%login_error_label.text = error_message
			%login_error_label.modulate = Color(1, 0, 0)
		elif current_request_type == "REGISTER" and has_node("%register_error_label"):
			%register_error_label.text = error_message
			%register_error_label.modulate = Color(1, 0, 0)

# --- LOGIN/LOGOUT ---
func _on_open_login_pressed():
	if Global.is_logged_in(): 
		# Wylogowanie
		Global.access_token = ""
		Global.refresh_token = ""
		Global.username = ""
		
		# Odśwież UI
		update_ui_after_login()
		shop_button.visible = false 
	else:
		# Otwieranie overlay logowania
		auth_overlay.visible = true
		login_form.visible = true
		register_form.visible = false
		clear_error_labels()
		if has_node("%login_pwd_input"):
			%login_pwd_input.text = ""


func update_login_button_text():
	if Global.is_logged_in():
		login_button.text = "Logout"
	else:
		login_button.text = "Login"



	update_ui_after_login()
	shop_button.visible = false

# --- NAWIGACJA ---
func _on_go_to_register_pressed():
	login_form.visible = false
	register_form.visible = true
	clear_error_labels()

func _on_back_to_login_pressed():
	register_form.visible = false
	login_form.visible = true
	clear_error_labels()

func _on_close_auth_pressed():
	auth_overlay.visible = false

# --- POZOSTAŁE ---
func _process(delta):
	if loading_icon.visible:
		loading_icon.rotation += delta * 5

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

func _on_shop_button_pressed():
	# Wywołujemy funkcję wewnątrz skryptu sklepu
	if shop.has_method("open_shop"):
		shop.open_shop()
	else:
		# Zapasowe otwarcie (gdyby skrypt sklepu nie działał)
		shop.visible = true
