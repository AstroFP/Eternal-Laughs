extends Control

# Ładujemy foremkę karty broni
var weapon_card_scene = preload("res://scenes/weapon_card.tscn")

# URL do API (zmień jeśli kolega ma inny)
const SHOP_URL = "http://127.0.0.1:8000/api/weapons/"

func _ready():
	# Możemy wyczyścić grid na starcie
	clear_grid()

# Ta funkcja zostanie wywołana z Main Menu, gdy gracz kliknie przycisk
func open_shop():
	self.visible = true
	fetch_items()

# Pobieranie danych z serwera
func fetch_items():
	print("Sklep: Pobieram towary...")
	
	# Tworzymy dynamicznie listonosza (HTTPRequest)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_data_received.bind(http))
	
	var error = http.request(SHOP_URL)
	if error != OK:
		print("Błąd połączenia ze sklepem!")
		http.queue_free()

# Odbiór paczki
func _on_data_received(_result, response_code, _headers, body, http_node):
	http_node.queue_free() # Usuwamy listonosza
	
	if response_code != 200:
		print("Błąd sklepu: ", response_code)
		return
		
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result == OK:
		var data = json.get_data()
		if data is Array:
			populate_grid(data)
		else:
			print("Sklep: Otrzymane dane nie są listą!")
	else:
		print("Sklep: Błąd parsowania JSON")

# Wypełnianie półek
func populate_grid(items: Array):
	clear_grid()
	
	for item_data in items:
		var card = weapon_card_scene.instantiate()
		%item_grid.add_child(card) # Tutaj %item_grid zadziała idealnie!
		card.set_data(item_data)

# Czyszczenie starych kart
func clear_grid():
	for child in %item_grid.get_children():
		child.queue_free()

# Obsługa przycisku zamknięcia (jeśli jest wewnątrz tej sceny)
func _on_close_shop_button_pressed():
	self.visible = false
