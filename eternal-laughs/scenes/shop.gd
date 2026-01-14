extends Control

# Ładujemy foremkę karty broni
var weapon_card_scene = preload("res://scenes/weapon_card.tscn")

# URL do API (zmień jeśli kolega ma inny)
const SHOP_URL = "http://localhost:8000/shop/items"

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


# Wypełnianie półek
func populate_grid(items: Array):
	clear_grid()
	
	for item_data in items:
		var card = weapon_card_scene.instantiate()
		%item_grid.add_child(card) # Tutaj %item_grid zadziała idealnie!
		print(card)
		
		card.set_data(item_data)

# Czyszczenie starych kart
func clear_grid():
	for child in %item_grid.get_children():
		child.queue_free()

# Obsługa przycisku zamknięcia (jeśli jest wewnątrz tej sceny)
func _on_close_shop_button_pressed():
	self.visible = false

func _on_back_button_pressed():
	self.visible = false
