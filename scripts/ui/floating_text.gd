extends Label


func _ready():
	# Animasi teks melayang ke atas dan menghilang
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 1.5)
	tween.tween_property(self, "modulate:a", 0, 1.5)
	tween.chain().tween_callback(queue_free)


static func create(parent: Node, pos: Vector2, text: String, color: Color = Color.WHITE):
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Gunakan font size kecil
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.modulate = color
	lbl.set_script(load("res://scripts/ui/floating_text.gd"))

	# Pusatkan teks di atas posisi
	lbl.position = pos - Vector2(50, 20)
	lbl.custom_minimum_size = Vector2(100, 20)

	parent.add_child(lbl)
