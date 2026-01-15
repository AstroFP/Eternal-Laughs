extends PanelContainer

signal action_pressed(id)

var my_id = -1
var is_inventory = false
var current_http_request: HTTPRequest = null

func _ready():
	# Zabezpieczenie przed podwójnym podłączeniem
	if %buy_button.pressed.is_connected(_on_buy_button_pressed):
		%buy_button.pressed.disconnect(_on_buy_button_pressed)
	%buy_button.pressed.connect(_on_buy_button_pressed)

func set_data(data: Dictionary, is_inventory_mode = false):
	is_inventory = is_inventory_mode
	
	var item_info = data
	if data.has("item"):
		item_info = data["item"]
	
	my_id = data.get("id", -1)
	
	# Pobieramy nazwę
	var item_name = str(item_info.get("name", "Unknown"))
	if has_node("%name_label"):
		%name_label.text = item_name
	
	# Statystyki
	if has_node("%stats_label"):
		var atk = item_info.get("attack", 0)
		var def = item_info.get("defense", 0)
		%stats_label.text = "ATAK: " + str(atk) + "\nOBRONA: " + str(def)
	
	# Przycisk
	if has_node("%buy_button"):
		if is_inventory:
			if data.get("is_equipped", false):
				%buy_button.text = "ZDEJMIJ"
				%buy_button.modulate = Color(1, 0, 0)
			else:
				%buy_button.text = "ZAŁÓŻ"
				%buy_button.modulate = Color(0, 1, 0)
		else:
			var price = item_info.get("price", 0)
			%buy_button.text = "KUP (" + str(price) + ")"
			%buy_button.modulate = Color(1, 1, 1)

	# --- HACK NA PREZENTACJĘ: RĘCZNE PRZYPISANIE OBRAZKÓW ---
	var url = item_info.get("image_url", "")
	
	if "Pepe" in item_name:
		url = "http://127.0.0.1:8000/equipment/pepe.png"
	elif "Medal" in item_name or "67" in item_name:
		url = "http://127.0.0.1:8000/equipment/sixseven.png"
	elif "Nabój" in item_name or "Super" in item_name:
		url = "http://127.0.0.1:8000/equipment/naboj.png"
		
	if url != "":
		print("Pobieram obrazek dla: " + item_name + " z URL: " + url)
		load_image_from_url(url)
	else:
		print("Brak URL dla: " + item_name)

func _on_buy_button_pressed():
	emit_signal("action_pressed", my_id)

# --- Obsługa pobierania obrazka ---
func load_image_from_url(url: String):
	if current_http_request != null:
		current_http_request.queue_free()
	
	current_http_request = HTTPRequest.new()
	add_child(current_http_request)
	
	# --- TU BYŁ BŁĄD! Dodaliśmy .bind(current_http_request) ---
	# Dzięki temu funkcja _on_image_downloaded dostanie ten brakujący 5. argument
	current_http_request.request_completed.connect(_on_image_downloaded.bind(current_http_request))
	
	var headers = PackedStringArray([]) 
	var error = current_http_request.request(url, headers)
	if error != OK:
		print("Błąd startu pobierania obrazka: ", error)

# Ta funkcja wymaga 5 argumentów. Teraz je dostanie.
func _on_image_downloaded(result, response_code, headers, body, http_node):
	if http_node:
		http_node.queue_free()

	# Czyścimy referencję jeśli to ten sam request
	if current_http_request == http_node:
		current_http_request = null

	if response_code == 200:
		var img = Image.new()
		var error = img.load_png_from_buffer(body)
		
		if error != OK:
			error = img.load_jpg_from_buffer(body)
		
		if error == OK:
			var tex = ImageTexture.create_from_image(img)
			if %icon:
				%icon.texture = tex
				%icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				%icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	else:
		print("Błąd pobierania grafiki. Kod HTTP: ", response_code)
