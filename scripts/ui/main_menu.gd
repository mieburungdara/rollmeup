extends Control

@onready var about_popup = $AboutPopup
@onready var map_size_popup = $MapSizePopup
@onready var editor_map_popup = $EditorMapPopup


func _ready() -> void:
    var generator = load("res://scripts/core/asset_generator.gd").new()
    add_child(generator)


func _on_new_game_pressed() -> void:
    GameSettings.is_editor_mode = false
    GameSettings.map_type = 0  # 0: Natural/Random
    get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_editor_pressed() -> void:
    editor_map_popup.popup_centered()


func _open_editor(type: int) -> void:
    GameSettings.is_editor_mode = true
    GameSettings.map_type = type
    get_tree().change_scene_to_file("res://scenes/main.tscn")


func _set_map_type(type: int) -> void:
    GameSettings.map_type = type


func _on_about_pressed() -> void:
    about_popup.popup_centered()


func _on_quit_pressed() -> void:
    get_tree().quit()
