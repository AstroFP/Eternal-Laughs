extends PanelContainer

var item_data = {}
@onready var item_icon = %icon  # Twój TextureRect

var current_http_request: HTTPRequest = null  # przechowamy instancję HTTPRequest

func set_data(data: Dictionary):
	item_data = data
	
	# Nazwa
	%name_label.text = str(data.get("name", "Nieznany przedmiot"))
	
	# Statystyki
	var stats_text = ""
	if data.has("attack"):
		stats_text += "Atak: " + str(data["attack"]) + "\n"
	if data.has("defense"):
		stats_text += "Obrona: " + str(data["defense"])
	%stats_label.text = stats_text
	
	# Cena
	var price = data.get("price", 0)
	%buy_button.text = "KUP (" + str(price) + ")"
	
	# Ikona
	if data.has("image_url") and data["image_url"] != "":
		load_image_from_url(data["image_url"])

func _on_buy_button_pressed():
	print("Kupiono: ", item_data.get("name"))

# --- pobieranie obrazka ---
# --- pobieranie obrazka ---
func load_image_from_url(url: String):
	current_http_request = HTTPRequest.new()
	add_child(current_http_request)
	
	# Opcjonalne: Wyłącz weryfikację certyfikatu, jeśli HTTPS sprawia problemy
	# current_http_request.set_tls_verify_node(false)
	
	# WAŻNE: W Godot 4 używamy .connect(funkcja)
	current_http_request.request_completed.connect(_on_image_downloaded)
	
	# Jeśli obrazek na Cloudinary nie jest publiczny, dodaj nagłówek z tokenem
	# Ale zazwyczaj URL z Cloudinary są publiczne, więc nagłówki są puste:
	var headers = PackedStringArray([]) 
	
	var error = current_http_request.request(url, headers)
	if error != OK:
		print("Błąd wysyłania zapytania o obraz:", error)

# USUNIĘTO 5. ARGUMENT "request" - teraz są 4
func _on_image_downloaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if current_http_request:
		current_http_request.queue_free()
		current_http_request = null

	print("Pobieranie obrazka - status HTTP: ", response_code)

	if response_code == 200:
		var img = Image.new()
		
		# Ponieważ Twój link kończy się na .png, używamy konkretnej metody:
		var error = img.load_png_from_buffer(body)
		
		# Jeśli jednak Cloudinary zmieni format w locie, to dla pewności:
		if error != OK:
			error = img.load_jpg_from_buffer(body)
		
		if error == OK:
			# Tworzymy teksturę z załadowanego obrazu
			var tex = ImageTexture.create_from_image(img)
			
			if %icon:
				%icon.texture = tex
				print("Sukces: Obrazek wyświetlony!")
			else:
				print("Błąd: Nie znaleziono węzła %item_icon w scenie")
		else:
			print("Błąd: Nie udało się zdekodować danych obrazu. Kod błędu Godot:", error)
	else:
		print("Błąd: Serwer Cloudinary zwrócił kod: ", response_code)
