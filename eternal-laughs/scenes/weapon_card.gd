extends PanelContainer

# Zmienna przechowująca dane tej konkretnej broni (id, cena itd.)
var item_data = {}

# Funkcja, którą wywołamy ze sklepu, żeby wypełnić kartę
func set_data(data: Dictionary):
	item_data = data
	print(item_data)
	
	# 1. Ustawiamy Nazwę
	# Używamy .get("name", "Brak"), żeby gra nie wywaliła się, jak pola brakuje
	%name_label.text = str(data.get("name", "Nieznany przedmiot"))
	
	# 2. Ustawiamy Statystyki (składamy napis z ataku i obrony)
	var stats_text = ""
	if data.has("attack"):
		stats_text += "Atak: " + str(data["attack"]) + "\n"
	if data.has("defense"):
		stats_text += "Obrona: " + str(data["defense"])
	
	%stats_label.text = stats_text
	
	# 3. Ustawiamy przycisk ceny
	var price = data.get("price", 0)
	%buy_button.text = "KUP (" + str(price) + ")"
	
	# 4. Ikona (na razie placeholder, bo w JSON nie ma URL)
	# W przyszłości: if data.has("image_url"): ...

# Sygnał kliknięcia kupna (opcjonalnie podepniemy później w sklepie)
func _on_buy_button_pressed():
	print("Kupiono: ", item_data.get("name"))
