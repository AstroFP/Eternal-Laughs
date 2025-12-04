extends Control

const game_path = "res://scenes/game_level.tscn"

@onready var auth_overlay = %auth_overlay
@onready var login_form = %login_form
@onready var register_form = %register_form
@onready var login_button = $login_button # To jest blisko, może zostać $
@onready var close_button = %close_button

# 1. Referencja do węzła HTTP (Twojego listonosza)
@onready var http_sender = $http_request

# Adresy Twojego API (zmień na prawdziwe adresy kolegi!)
# Pamiętaj: w Godot localhost to często 127.0.0.1
const URL_LOGIN = "http://127.0.0.1:8000/api/login/"
const URL_REGISTER = "http://127.0.0.1:8000/api/register/"

func _ready() -> void:
	
	$menu_container/new_game_button.disabled = true
	$menu_container/load_game_button.disabled = true
	
	$login_button.grab_focus()
	
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
	
	# Przycisk ZALOGUJ w formularzu logowania
	var btn_submit_login = %login_form.get_node("submit_login_button")
	btn_submit_login.pressed.connect(_on_submit_login_pressed)
	
	# Przycisk ZAREJESTRUJ w formularzu rejestracji
	var btn_submit_reg = %register_form.get_node("register_button")
	btn_submit_reg.pressed.connect(_on_submit_register_pressed)
	
	# Podpinamy sygnał odbioru wiadomości od serwera
	http_sender.request_completed.connect(_on_server_responded)
	

func _on_submit_login_pressed():
	# 1. Wyciągamy dane z pól (dzięki % jest krótko)
	var email = %login_email_input.text
	var password = %login_pwd_input.text
	
	# Szybka walidacja (czy nie puste)
	if email == "" or password == "":
		print("Błąd: Puste pola!")
		return

	# 2. Pakujemy w słownik (to zrozumie Django)
	var data_to_send = {
		"email": email,
		"password": password
	}
	
	# 3. Zamieniamy na JSON i wysyłamy
	print("Wysyłam logowanie...", data_to_send)
	send_post_request(URL_LOGIN, data_to_send)


# --- LOGIKA REJESTRACJI ---

func _on_submit_register_pressed():
	var username = %reg_username_input.text
	var email = %reg_email_input.text
	var pass1 = %reg_pwd_input.text
	var pass2 = %reg_pwd_repeat_input.text
	
			
	if username == "" or email == "" or pass1 == "":
		print("Błąd: Wypełnij wszystkie pola")
		return

	# Pakujemy dane dla Django
	var data_to_send = {
		"username": username,
		"email": email,
		"password": pass1,
		"password2": pass2
	}
	
	print("Wysyłam rejestrację...", data_to_send)
	send_post_request(URL_REGISTER, data_to_send)
	
	# --- FUNKCJA POMOCNICZA DO WYSYŁANIA ---

func send_post_request(url: String, data: Dictionary):
	# Nagłówki są konieczne, żeby Django wiedział, że dostaje JSONa
	var headers = ["Content-Type: application/json"]
	
	# Zamiana słownika Godota na tekst JSON
	var json_body = JSON.stringify(data)
	
	# Strzał! (Metoda POST)
	var error = http_sender.request(url, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		print("Błąd połączenia z siecią! Kod błędu: ", error)


func _on_server_responded(result, response_code, headers, body):
	print("Serwer odpowiedział! Kod:", response_code)
	
	# Odkodowanie odpowiedzi (z JSONa na zmienne Godota)
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		print("Błąd parsowania JSONa z serwera")
		return
		
	var response_data = json.get_data() # To jest słownik z odpowiedzią backendu
	print("Dane z serwera: ", response_data)
	
	# PRZYKŁAD REAKCJI:
	if response_code == 200 or response_code == 201:
		print("Sukces!")
		auth_overlay.visible = false
		$menu_container/new_game_button.disabled = false
		$menu_container/load_game_button.disabled = false
		$menu_container/new_game_button.grab_focus()
	elif response_code == 401 or response_code == 400:
		print("Błąd logowania: Nieprawidłowe dane.")
		# Tu możesz np. zmienić tekst w jakimś Labelu na czerwono "Błędne hasło"
		
	else:
		print("Inny błąd serwera.")
		
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
