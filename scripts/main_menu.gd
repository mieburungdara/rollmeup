extends Control

@onready var about_popup = $AboutPopup

func _on_new_game_pressed() -> void:
	# Pindah ke scene permainan utama
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	# Placeholder: Bisa ditambahkan scene settings nanti
	print("Settings clicked - Coming Soon")

func _on_about_pressed() -> void:
	about_popup.popup_centered()

func _on_quit_pressed() -> void:
	get_tree().quit()
