extends Camera2D

var zoom_speed := 0.1
var min_zoom := 0.5
var max_zoom := 5.0
var move_speed := 600.0

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1
	if Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	
	if input_dir != Vector2.ZERO:
		# Bergerak lebih cepat jika di-zoom out (zoom.x lebih kecil)
		position += input_dir.normalized() * (move_speed / zoom.x) * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative / zoom
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom_level(zoom.x + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom_level(zoom.x - zoom_speed)

func _set_zoom_level(level: float) -> void:
	var z = clamp(level, min_zoom, max_zoom)
	zoom = Vector2(z, z)
