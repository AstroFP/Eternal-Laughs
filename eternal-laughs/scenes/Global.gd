extends Node

# Dane logowania
var username: String = ""
var email: String = ""
var access_token: String = ""
var refresh_token: String = ""

# Sprawdzenie czy jesteśmy zalogowani
func is_logged_in() -> bool:
	return access_token != ""
