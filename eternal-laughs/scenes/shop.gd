extends Control

# Ładujemy foremkę karty broni
var weapon_card_scene = preload("res://scenes/weapon_card.tscn")

# URL do API (zmień jeśli kolega ma inny)
const SHOP_URL = "http://127.0.0.1:8000/shop/items/"
const BUY_URL_BASE = "http://127.0.0.1:8000/shop/buy/"
func _ready():
	# Możemy wyczyścić grid na starcie
	clear_grid()
	%exit_button.pressed.connect(_on_back_button_pressed)

# Ta funkcja zostanie wywołana z Main Menu, gdy gracz kliknie przycisk
func open_shop():
	self.visible = true
	fetch_items()

# Pobieranie danych z serwera
func fetch_items():
	print("Sklep: Pobieram towary...")

	var http = HTTPRequest.new()
	add_child(http)
	
	# Używamy nowej składni sygnałów Godot 4
	http.request_completed.connect(_on_data_received)

	var headers = PackedStringArray(["Authorization: Bearer " + Global.access_token])

	var error = http.request(SHOP_URL, headers, HTTPClient.METHOD_GET)

	if error != OK:
		print("Błąd startu requestu:", error)
		http.queue_free()



# Odbiór paczki
# 1. Zmieniona liczba argumentów (z 5 na 4)
func _on_data_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	# Ten print powie nam, czy Godot w ogóle usłyszał serwer
	print("--- SYGNAŁ ODEBRANY ---")
	print("Kod HTTP: ", response_code)

	# Usuwamy HTTPRequest (szukamy go w dzieciach, bo nie mamy go już w argumencie)
	for child in get_children():
		if child is HTTPRequest:
			child.queue_free()

	if response_code != 200:
		print("Błąd serwera! Treść: ", body.get_string_from_utf8())
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result == OK:
		var data = json.get_data()
		if data is Array:
			populate_grid(data)
		else:
			print("Błąd: Dane to nie lista, tylko: ", typeof(data))
	else:
		print("Błąd parsowania JSON")

func _on_buy_item(item_id):
	print("Próba kupna przedmiotu ID: ", item_id)
	
	# --- TU BRAKOWAŁO TWORZENIA HTTPREQUEST ---
	var http = HTTPRequest.new()
	add_child(http)
	# Podłączamy odpowiedź do nowej funkcji _on_buy_completed
	http.request_completed.connect(_on_buy_completed.bind(http))
	
	var url = BUY_URL_BASE + str(int(item_id)) + "/"
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Global.access_token
	]
	
	# Teraz zmienna 'http' już istnieje, więc to zadziała:
	var error = http.request(url, headers, HTTPClient.METHOD_POST, "")
	
	if error != OK:
		print("Błąd wysyłania żądania kupna: ", error)
		http.queue_free()
		

func _on_buy_completed(result, response_code, headers, body, http_node):
	# Sprzątamy zużyty HTTPRequest
	http_node.queue_free()
	
	if response_code == 200 or response_code == 201:
		print("SUKCES! Przedmiot kupiony.")
		
		# --- TWORZENIE POWIADOMIENIA (POPUP) ---
		var dialog = AcceptDialog.new()
		dialog.title = "Sukces!"
		dialog.dialog_text = "Zakup udany! Przedmiot został dodany do Twojego ekwipunku."
		dialog.ok_button_text = "Super"
		
		# Ważne: usuwamy okienko z pamięci, gdy gracz kliknie OK
		dialog.confirmed.connect(dialog.queue_free)
		dialog.canceled.connect(dialog.queue_free) # na wypadek kliknięcia X
		
		add_child(dialog)
		dialog.popup_centered() # Wyświetl na środku ekranu
		# ---------------------------------------
		
		# Odświeżamy listę towarów (opcjonalne, ale warto)
		fetch_items()
		
	else:
		print("Błąd zakupu. Kod: ", response_code)
		
		# --- POWIADOMIENIE O BŁĘDZIE ---
		var dialog = AcceptDialog.new()
		dialog.title = "Błąd"
		dialog.dialog_text = "Nie masz wystarczająco środków lub wystąpił błąd serwera.\nKod: " + str(response_code)
		dialog.confirmed.connect(dialog.queue_free)
		
		add_child(dialog)
		dialog.popup_centered()

# Wypełnianie półek
func populate_grid(items: Array):
	clear_grid()
	
	for item_data in items:
		var card = weapon_card_scene.instantiate()
		%item_grid.add_child(card)
		
		# Ustawiamy dane (false = tryb sklepu)
		card.set_data(item_data, false) 
		
		# --- TO JEST KLUCZOWE: Podłączamy sygnał z karty do funkcji kupowania ---
		if not card.action_pressed.is_connected(_on_buy_item):
			card.action_pressed.connect(_on_buy_item)

# Czyszczenie starych kart
func clear_grid():
	for child in %item_grid.get_children():
		child.queue_free()

# Obsługa przycisku zamknięcia (jeśli jest wewnątrz tej sceny)
func _on_close_shop_button_pressed():
	self.visible = false

func _on_back_button_pressed():
	self.visible = false
