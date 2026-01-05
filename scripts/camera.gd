extends Camera2D

var zoom_target := Vector2(1.0, 1.0)
var zoom_speed := 5.0 
var min_zoom := 0.1 
var max_zoom := 4.0 # Batasi max zoom agar tidak terlalu dekat (mencegah crash rendering)
var move_speed := 1000.0

func _process(delta: float) -> void:
	# Pastikan zoom tidak pernah 0 untuk menghindari crash matematika
	if zoom.x <= 0.01: zoom = Vector2(0.01, 0.01)
	
	# Pergerakan WASD
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1
	if Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	
	if input_dir != Vector2.ZERO:
		# Bergerak lebih cepat jika di-zoom out (safety check zoom.x > 0)
		position += input_dir.normalized() * (move_speed / max(zoom.x, 0.01)) * delta
	
	# Smooth Zoom Interpolation
	zoom = zoom.lerp(zoom_target, zoom_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative / max(zoom.x, 0.01)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_target *= 1.1 
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_target *= 0.9 
			
			# Clamp zoom target secara ketat
			var z = clamp(zoom_target.x, min_zoom, max_zoom)
			zoom_target = Vector2(z, z)
