extends Sprite2D

var decay_timer: float = 30.0  # Detik sebelum menghilang sepenuhnya


func _ready():
	texture = load("res://assets/world_tiles.png")
	region_enabled = true
	region_rect = Rect2(15 * 32, 0, 32, 32)
	z_index = -1  # Di bawah unit yang hidup
	modulate.a = 0.8


func _process(delta):
	decay_timer -= delta

	# Mulai memudar saat waktu tinggal sedikit
	if decay_timer < 10.0:
		modulate.a = decay_timer / 10.0

	if decay_timer <= 0:
		queue_free()
