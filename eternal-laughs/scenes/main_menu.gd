extends Control

const game_path = "res://scenes/game_level.tscn"

# --- ZMIENNE UI ---
@onready var auth_overlay = %auth_overlay
@onready var login_form = %login_form
@onready var register_form = %register_form


@onready var login_button = %login_button 
@onready var close_button = %close_button
@onready var user_label = %user_label 

# HTTP Request
@onready var http_sender = $http_request

# Zmienne stanu
var current_request_type = ""
var is_logged_in = false

# Adresy API
const URL_LOGIN = "http://127.0.0.1:8000/api/auth/login/"
const URL_REGISTER = "http://127.0.0.1:8000/api/auth/register/"

func _ready() -> void:
	# 1. Blokada gry na start
	$menu_container/new_game_button.disabled = true
	$menu_container/load_game_button.disabled = true

	login_button.grab_focus()
	
	# 3. Animacja tytułu
	if has_node("title"):
		var title_node = $title
		title_node.pivot_offset = title_node.size / 2
		var tween = create_tween().set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(title_node, "scale", Vector2(1.1, 1.1), 1.5)
		tween.tween_property(title_node, "scale", Vector2(1.0, 1.0), 1.5)
	
	# 4. Overlay ukryty na start
	auth_overlay.visible = false
	if user_label: user_label.visible = false
	
	# 5. Podpinanie sygnałów (Główne)
	login_button.pressed.connect(_on_open_login_pressed)
	close_button.pressed.connect(_on_close_auth_pressed)
	
	# 6. Nawigacja wewnątrz formularzy
	var go_reg_btn = login_form.get_node("go_to_register_button")
	go_reg_btn.pressed.connect(_on_go_to_register_pressed)
	
	var back_login_btn = register_form.get_node("back_to_login_button")
	back_login_btn.pressed.connect(_on_back_to_login_pressed)
	
	# 7. Wysyłanie formularzy
	var btn_submit_login = login_form.get_node("submit_login_button")
	btn_submit_login.pressed.connect(_on_submit_login_pressed)
	
	var btn_submit_reg = register_form.get_node("register_button")
	btn_submit_reg.pressed.connect(_on_submit_register_pressed)
	
	# 8. Odpowiedź serwera
	http_sender.request_completed.connect(_on_server_responded)

# --- LOGOWANIE ---
func _on_submit_login_pressed():
	var email = %login_email_input.text
	var password = %login_pwd_input.text
	
	if email == "" or password == "":
		print("Błąd: Puste pola!")
		return

	var data_to_send = {"email": email, "password": password}
	current_request_type = "LOGIN"
	
	print("Wysyłam logowanie...", data_to_send)
	send_post_request(URL_LOGIN, data_to_send)

# --- REJESTRACJA ---
func _on_submit_register_pressed():
	var username = %reg_username_input.text
	var email = %reg_email_input.text
	var pass1 = %reg_pwd_input.text
	var pass2 = %reg_pwd_repeat_input.text
	
	if username == "" or email == "" or pass1 == "":
		print("Błąd: Wypełnij wszystkie pola")
		return

	# Walidacja haseł po stronie klienta
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
	
	print("Wysyłam rejestrację...", data_to_send)
	send_post_request(URL_REGISTER, data_to_send)

# --- HTTP HELPER ---
func send_post_request(url: String, data: Dictionary):
	var headers = ["Content-Type: application/json"]
	var json_body = JSON.stringify(data)
	var error = http_sender.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		print("Błąd połączenia z siecią! Kod błędu: ", error)

# --- ODBIÓR ODPOWIEDZI ---
func _on_server_responded(_result, response_code, _headers, body):
	# 1. Parsowanie JSON
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	var response_data = {}
	
	if parse_result == OK:
		response_data = json.get_data()
		print("DANE Z SERWERA: ", response_data) # Podgląd w konsoli

	# --- SCENARIUSZ: SUKCES (200 OK / 201 Created) ---
	if response_code == 200 or response_code == 201:
		# Czyścimy stare błędy
		if has_node("%login_error_label"): %login_error_label.text = ""
		if has_node("%register_error_label"): %register_error_label.text = ""
		
		if current_request_type == "LOGIN":
			print("Zalogowano!")
			
			# Zmiana stanu
			is_logged_in = true
			auth_overlay.visible = false
			
			# Odblokowanie gry
			$menu_container/new_game_button.disabled = false
			$menu_container/load_game_button.disabled = false
			$menu_container/new_game_button.grab_focus()
			
			# Zmiana przycisku na WYLOGUJ
			login_button.text = "LOGOUT"
			
			# Powitanie
			var user_name = "Graczu"
			if response_data.has("username"):
				user_name = str(response_data["username"])
			elif response_data.has("email"):
				user_name = str(response_data["email"])
			
			if user_label:
				user_label.text = "Witaj " + user_name + "!"
				user_label.visible = true
			
		elif current_request_type == "REGISTER":
			print("Zarejestrowano!")
			_on_back_to_login_pressed()
			
			# Info na zielono
			if has_node("%login_error_label"):
				%login_error_label.text = "Konto utworzone! Kliknij link w e-mailu."
				%login_error_label.modulate = Color(0, 1, 0)

	# --- SCENARIUSZ: BŁĄD (400+) ---
	elif response_code >= 400:
		var error_message = "Wystąpił nieznany błąd."
		
		# Logika wyciągania tekstu z Django
		if response_data.has("non_field_errors"):
			var errors = response_data["non_field_errors"]
			if errors is Array:
				error_message = "\n".join(errors)
			else:
				error_message = str(errors)
		elif response_data.has("detail"):
			error_message = response_data["detail"]
		elif response_data.has("password"):
			error_message = "Hasło: " + str(response_data["password"][0])
		elif response_data.has("email"):
			error_message = "Email: " + str(response_data["email"][0])
		elif response_data.has("username"):
			error_message = "Login: " + str(response_data["username"][0])

		print("BŁĄD DLA GRACZA: ", error_message)
		
		# Wyświetlenie
		if current_request_type == "LOGIN" and has_node("%login_error_label"):
			%login_error_label.text = error_message
			%login_error_label.modulate = Color(1, 0, 0) # Czerwony
		elif current_request_type == "REGISTER" and has_node("%register_error_label"):
			%register_error_label.text = error_message
			%register_error_label.modulate = Color(1, 0, 0)

# --- OBSŁUGA PRZYCISKU LOGIN/LOGOUT ---
func _on_open_login_pressed():
	if is_logged_in:
		# WYLOGOWYWANIE
		print("Wylogowywanie...")
		is_logged_in = false
		
		# Reset UI
		login_button.text = "LOGIN"
		if user_label:
			user_label.visible = false
			user_label.text = ""
		
		# Blokada gry
		$menu_container/new_game_button.disabled = true
		$menu_container/load_game_button.disabled = true
		login_button.grab_focus()
		
	else:
		# OTWARCIE OKNA
		auth_overlay.visible = true
		login_form.visible = true
		register_form.visible = false
		if has_node("%login_pwd_input"): %login_pwd_input.text = ""

# --- NAWIGACJA W OKNIE ---
func _on_go_to_register_pressed():
	login_form.visible = false
	register_form.visible = true
	# Czyścimy błędy przy przełączaniu
	if has_node("%register_error_label"): %register_error_label.text = ""

func _on_back_to_login_pressed():
	register_form.visible = false
	login_form.visible = true
	if has_node("%login_error_label"): %login_error_label.text = ""
	
func _on_close_auth_pressed():
	auth_overlay.visible = false

# --- POZOSTAŁE ---
func _process(_delta: float) -> void:
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
