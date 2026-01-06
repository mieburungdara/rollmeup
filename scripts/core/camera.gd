extends Camera2D

var zoom_target := Vector2(1.0, 1.0)
var zoom_speed := 5.0
var min_zoom := 0.1
var max_zoom := 4.0
var move_speed := 1000.0


func _process(delta: float) -> void:
	if zoom.x <= 0.01:
		zoom = Vector2(0.01, 0.01)

	# Pergerakan WASD
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1

	if input_dir != Vector2.ZERO:
		position += input_dir.normalized() * (move_speed / max(zoom.x, 0.01)) * delta

	# Smooth Zoom Interpolation
	zoom = zoom.lerp(zoom_target, zoom_speed * delta)

	# Batasi Kamera ke Batas Peta (Limits)
	_clamp_to_limits()

	position = position.round()


func _clamp_to_limits():
	# Ambil ukuran viewport saat ini
	var view_size = get_viewport_rect().size / zoom

	# Hitung batas aman agar kamera tidak melihat area kosong di luar peta
	var left = limit_left + (view_size.x / 2.0)
	var right = limit_right - (view_size.x / 2.0)
	var top = limit_top + (view_size.y / 2.0)
	var bottom = limit_bottom - (view_size.y / 2.0)

	# Jika peta lebih kecil dari layar, kunci di tengah
	if left > right:
		position.x = (limit_left + limit_right) / 2.0
	else:
		position.x = clamp(position.x, left, right)

	if top > bottom:
		position.y = (limit_top + limit_bottom) / 2.0
	else:
		position.y = clamp(position.y, top, bottom)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if (
			(event.button_mask & MOUSE_BUTTON_MASK_MIDDLE)
			or (event.button_mask & MOUSE_BUTTON_MASK_RIGHT)
		):
			position -= event.relative / max(zoom.x, 0.01)

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_target *= 1.1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_target *= 0.9

			var z = clamp(zoom_target.x, min_zoom, max_zoom)
			zoom_target = Vector2(z, z)
