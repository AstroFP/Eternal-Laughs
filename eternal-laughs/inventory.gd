extends Control

var weapon_card_scene = preload("res://scenes/weapon_card.tscn")

# Adresy API
const INVENTORY_URL = "http://127.0.0.1:8000/inventory/my"
const ACTION_BASE_URL = "http://127.0.0.1:8000/inventory/"

# Zmienna pomocnicza, żeby nie pobierać tego samego obrazka w kółko
var current_equipped_url = ""

func _ready():
	# Obsługa przycisku wyjścia
	if has_node("%exit_button"):
		%exit_button.pressed.connect(func(): visible = false)
	
	# Na starcie czyścimy rękę (używamy małych liter!)
	%hand_weapon.texture = null

func open_inventory():
	visible = true
	fetch_inventory()

# --- 1. POBIERANIE EKWIPUNKU ---
func fetch_inventory():
	print("Pobieram ekwipunek...")
	
	# Czyścimy stare
	for child in %item_grid.get_children():
		child.queue_free()
	%hand_weapon.texture = null
	current_equipped_url = ""
		
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_inventory_received.bind(http))
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Global.access_token
	]
	
	http.request(INVENTORY_URL, headers)

func _on_inventory_received(result, code, headers, body, http):
	http.queue_free()
	
	if code != 200:
		print("Błąd pobierania: ", code)
		return
		
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	
	if data is Array:
		for item_data in data:
			# A. Dodajemy kartę do listy po lewej
			var card = weapon_card_scene.instantiate()
			%item_grid.add_child(card)
			
			# 'true' oznacza tryb ekwipunku (obsługa zagnieżdżonego "item")
			card.set_data(item_data, true) 
			card.action_pressed.connect(_on_use_item)
			
			# B. Sprawdzamy czy ten przedmiot jest założony
			# JSON: { "is_equipped": true, "item": { "image_url": "..." } }
			if item_data.get("is_equipped") == true:
				var nested_item = item_data.get("item", {})
				var url = nested_item.get("image_url", "")
				
				# Jeśli mamy URL, ładujemy go do ręki
				if url != "":
					load_weapon_into_hand(url)
	else:
		print("Otrzymane dane to nie lista!")

# --- 2. ŁADOWANIE OBRAZKA DO RĘKI ---
func load_weapon_into_hand(url: String):
	if url == current_equipped_url:
		return # Już mamy ten obrazek, nie pobieramy ponownie
		
	current_equipped_url = url
	print("Zakładam do ręki: ", url)
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(res, code, head, body):
		http.queue_free()
		if code == 200:
			var img = Image.new()
			var err = img.load_png_from_buffer(body)
			if err != OK: 
				img.load_jpg_from_buffer(body) # Próba JPG jeśli PNG nie zadziała
			
			if err == OK:
				var tex = ImageTexture.create_from_image(img)
				# Tutaj przypisujemy teksturę do węzła z małą literą!
				%hand_weapon.texture = tex
	)
	http.request(url)

# --- 3. LOGIKA KLIKNIĘCIA "ZAŁÓŻ / ZDEJMIJ" ---
func _on_use_item(inventory_id):
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_action_response.bind(http))
	
	var url = ACTION_BASE_URL + str(int(inventory_id)) + "/use/"
	
	# --- TU TEŻ DODAJEMY TOKEN ---
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + Global.access_token
	]
	
	# POST z pustym body, ale z nagłówkami
	http.request(url, headers, HTTPClient.METHOD_POST, "")

func _on_action_response(result, code, headers, body, http):
	http.queue_free()
	
	if code == 200 or code == 201:
		print("Zmiana ekwipunku udana! Odświeżam widok...")
		# Pobieramy wszystko od nowa - dzięki temu ręka zaktualizuje się sama
		fetch_inventory()
	else:
		print("Błąd zmiany: ", code)
