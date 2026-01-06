extends Node


func _ready():
    print("Men-generate Atlas Potongan Tubuh (Modular)...")
    generate_world_atlas("res://assets/world_tiles.png")
    generate_modular_parts()


func generate_modular_parts():
    generate_part_atlas("res://assets/parts_heads.png", 32, 32, 5, _draw_head_variant)
    generate_part_atlas("res://assets/parts_eyes.png", 32, 32, 5, _draw_eyes_variant)
    generate_part_atlas("res://assets/parts_bodies.png", 32, 32, 5, _draw_body_variant)
    generate_part_atlas("res://assets/parts_arms.png", 32, 32, 5, _draw_arms_variant)
    generate_part_atlas("res://assets/parts_legs.png", 32, 32, 5, _draw_legs_variant)
    generate_part_atlas("res://assets/parts_hair.png", 32, 32, 5, _draw_hair_variant)

    _gen_simple_baked("res://assets/orc.png", Color(0.4, 0.6, 0.2))
    _gen_simple_baked("res://assets/elf.png", Color(0.8, 0.9, 0.7))


func generate_part_atlas(path: String, w: int, h: int, count: int, draw_func: Callable):
    var img = Image.create(w * count, h, false, Image.FORMAT_RGBA8)
    for i in range(count):
        draw_func.call(img, i * w, i)
    img.save_png(path)


func _draw_head_variant(img: Image, offset: int, variant: int):
    var base = Color.WHITE
    _draw_rect_custom(img, offset + 11, 4, 10, 10, base)
    if variant == 1:
        img.set_pixel(offset + 10, 7, base)
        img.set_pixel(offset + 9, 6, base)
        img.set_pixel(offset + 21, 7, base)
        img.set_pixel(offset + 22, 6, base)
    elif variant == 2:
        img.set_pixel(offset + 13, 13, Color.WHITE)
        img.set_pixel(offset + 18, 13, Color.WHITE)
    elif variant == 3:
        _draw_rect_custom(img, offset + 10, 5, 12, 9, base)
    elif variant == 4:
        _draw_rect_custom(img, offset + 12, 3, 8, 11, base)


func _draw_eyes_variant(img: Image, offset: int, variant: int):
    var c = Color.BLACK
    if variant == 0:
        img.set_pixel(offset + 13, 9, c)
        img.set_pixel(offset + 18, 9, c)
    elif variant == 1:
        img.set_pixel(offset + 13, 9, c)
        img.set_pixel(offset + 14, 9, c)
        img.set_pixel(offset + 17, 9, c)
        img.set_pixel(offset + 18, 9, c)
    elif variant == 2:
        img.set_pixel(offset + 13, 9, c)
        img.set_pixel(offset + 18, 9, c)
        img.set_pixel(offset + 12, 8, c)
        img.set_pixel(offset + 19, 8, c)
    else:
        img.set_pixel(offset + 13, 9, c)
        img.set_pixel(offset + 13, 8, Color.WHITE)
        img.set_pixel(offset + 18, 9, c)
        img.set_pixel(offset + 18, 8, Color.WHITE)


func _draw_body_variant(img: Image, offset: int, variant: int):
    var shirt = Color(1, 0, 0, 1)
    var w = 12
    var sx = 10
    if variant == 1:
        w = 16
        sx = 8
    elif variant == 3:
        w = 10
        sx = 11
    _draw_rect_custom(img, offset + sx, 14, w, 10, shirt)
    _draw_rect_custom(img, offset + sx, 19, w, 2, Color(0.2, 0.1, 0))


func _draw_arms_variant(img: Image, offset: int, variant: int):
    var base = Color.WHITE
    var aw = 3
    if variant == 1:
        aw = 4
    _draw_rect_custom(img, offset + 7, 15, aw, 8, base)
    _draw_rect_custom(img, offset + 25 - aw, 15, aw, 8, base)


func _draw_legs_variant(img: Image, offset: int, _variant: int):
    var boot = Color.WHITE
    _draw_rect_custom(img, offset + 11, 24, 3, 7, boot)
    _draw_rect_custom(img, offset + 18, 24, 3, 7, boot)


func _draw_hair_variant(img: Image, offset: int, variant: int):
    var base = Color.WHITE
    if variant == 0:
        _draw_rect_custom(img, offset + 11, 3, 10, 3, base)
    elif variant == 1:
        _draw_rect_custom(img, offset + 10, 3, 12, 12, base)
    elif variant == 2:
        _draw_rect_custom(img, offset + 14, 1, 4, 10, base)
    elif variant == 3:
        _draw_rect_custom(img, offset + 11, 11, 10, 6, base)
    elif variant == 4:
        _draw_rect_custom(img, offset + 11, 3, 10, 1, base)


func _draw_rect_custom(img: Image, x: int, y: int, w: int, h: int, color: Color):
    for i in range(x, x + w):
        for j in range(y, y + h):
            if i >= 0 and i < img.get_width() and j >= 0 and j < 32:
                img.set_pixel(i, j, color)


func generate_world_atlas(path: String):
    # Perluas atlas untuk menampung 21 ubin (32*21 = 672)
    var img = Image.create(672, 32, false, Image.FORMAT_RGBA8)
    var c_grass = Color(0.3, 0.6, 0.25)

    _fill_tile(img, 0, Color(0.1, 0.35, 0.7))
    _draw_clump(img, 0, 6, Color(0.2, 0.5, 0.9), 2)
    _fill_tile(img, 1, Color(0.9, 0.8, 0.5))
    for i in range(30):
        img.set_pixel(32 + randi() % 32, randi() % 32, Color(0.8, 0.7, 0.3))
    _draw_craggy_stone(img, 3, Color(0.4, 0.4, 0.4))
    _draw_natural_dirt(img, 5, Color(0.45, 0.3, 0.2))

    _draw_painterly_grass(img, 2, c_grass, 0)
    _draw_painterly_grass(img, 8, c_grass, 1)
    _draw_painterly_grass(img, 9, c_grass.darkened(0.1), 2)
    _draw_painterly_grass(img, 10, c_grass.lightened(0.1), 3)

    _draw_stone_resource(img, 7)
    _draw_hq_tree(img, 6, Color(0.1, 0.4, 0.1), Color(0.3, 0.2, 0.1))
    _draw_pine_tree(img, 11)
    _draw_hq_tree(img, 12, Color(0.2, 0.5, 0.2), Color(0.9, 0.9, 0.9))
    _draw_hq_tree(img, 13, Color(0.8, 0.4, 0.1), Color(0.3, 0.2, 0.1))
    _draw_hq_tree(img, 14, Color(0.1, 0.4, 0.1), Color(0.3, 0.2, 0.1))

    _draw_corpse_marker(img, 15)
    _draw_black_tile(img, 16)
    _draw_mega_wagon(img, 17)
    _draw_hut(img, 21)
    img.save_png(path)


func _draw_hut(img: Image, idx: int):
    var offset = idx * 32
    var c_wood = Color(0.35, 0.2, 0.1)
    var c_tent = Color(0.6, 0.5, 0.4)  # Warna kain kusam
    # Atap Segitiga (Kemah)
    for y in range(5, 15):
        var w = (y - 5) * 1.5
        _draw_rect_custom(img, offset + 16 - w / 2, y, w, 1, c_tent)
    # Tiang Kayu depan
    _draw_rect_custom(img, offset + 15, 15, 2, 12, c_wood)
    # Pintu Masuk
    _draw_rect_custom(img, offset + 14, 20, 4, 7, Color(0.1, 0.05, 0))


func _draw_mega_wagon(img: Image, start_idx: int):
    var c_wood = Color(0.3, 0.15, 0.05)
    var c_wood_lt = Color(0.5, 0.35, 0.2)
    var c_canvas = Color(0.75, 0.7, 0.6)
    var c_canvas_dk = Color(0.5, 0.45, 0.4)
    var c_iron = Color(0.1, 0.1, 0.15)

# --- ATAS (17 & 18) ---
    var tl = start_idx * 32
    _draw_rect_custom(img, tl + 8, 5, 24, 20, c_canvas)
    for i in range(6):
        img.set_pixel(tl + 8 + i, 5 + i, Color(0, 0, 0, 0))
    var tr = (start_idx + 1) * 32
    _draw_rect_custom(img, tr, 5, 22, 20, c_canvas)
    for y in range(5, 25):
        img.set_pixel(tr + 5, y, c_canvas_dk)
        img.set_pixel(tr + 15, y, c_canvas_dk)

# --- BAWAH (19 & 20) ---
    var bl = (start_idx + 2) * 32
    _draw_rect_custom(img, bl + 8, 0, 24, 12, c_wood)
    _draw_circle(img, bl + 16, 15, 10, c_iron)
    _draw_circle(img, bl + 16, 15, 8, c_wood)
    _draw_rect_custom(img, bl + 15, 14, 3, 3, c_iron)

    var br = (start_idx + 3) * 32
    _draw_rect_custom(img, br, 0, 18, 12, c_wood)
    _draw_rect_custom(img, br + 5, 12, 12, 4, c_iron)
    _draw_rect_custom(img, br + 18, 8, 14, 2, c_wood)
    img.set_pixel(br + 31, 8, c_wood_lt)

    for x in range(8, 32):
        img.set_pixel(bl + x, 5, Color.BLACK)
    for x in range(0, 18):
        img.set_pixel(br + x, 5, Color.BLACK)


func _draw_black_tile(img: Image, idx: int):
    var offset = idx * 32
    _draw_rect_custom(img, offset, 0, 32, 32, Color.BLACK)


func _draw_corpse_marker(img: Image, idx: int):
    var offset = idx * 32
    var c = Color(0.7, 0.7, 0.7)
    _draw_rect_custom(img, offset + 12, 18, 8, 10, c)
    _draw_rect_custom(img, offset + 14, 16, 4, 2, c)
    _draw_rect_custom(img, offset + 15, 18, 2, 6, Color(0.3, 0.3, 0.3))
    _draw_rect_custom(img, offset + 14, 20, 4, 2, Color(0.3, 0.3, 0.3))


func _gen_simple_baked(path, skin):
    var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
    _draw_rect_custom(img, 11, 4, 10, 10, skin)
    img.save_png(path)


func _draw_hq_tree(img: Image, idx: int, leaf_color: Color, trunk_color: Color):
    var offset = idx * 32
    _draw_rect_custom(img, offset + 14, 18, 4, 10, trunk_color)
    _draw_circle(img, offset + 16, 12, 10, leaf_color.darkened(0.2))
    _draw_circle(img, offset + 16, 10, 8, leaf_color)
    _draw_circle(img, offset + 13, 8, 4, leaf_color.lightened(0.2))


func _draw_pine_tree(img: Image, idx: int):
    var offset = idx * 32
    _draw_rect_custom(img, offset + 14, 22, 4, 6, Color(0.2, 0.1, 0.05))
    for i in range(3):
        var y = 18 - (i * 6)
        var w = 18 - (i * 4)
        for tx in range(-w / 2, w / 2):
            for ty in range(0, 8):
                if abs(tx) < (8 - ty) * (float(w) / 16.0):
                    img.set_pixel(offset + 16 + tx, y + ty, Color(0.05, 0.25, 0.05))


func _draw_circle(img: Image, cx: int, cy: int, radius: int, color: Color):
    for x in range(cx - radius, cx + radius):
        for y in range(cy - radius, cy + radius):
            if Vector2(x, y).distance_to(Vector2(cx, cy)) < radius:
                if x >= 0 and x < 672 and y >= 0 and y < 32:
                    img.set_pixel(x, y, color)


func _draw_natural_dirt(img: Image, idx: int, base_color: Color):
    var offset = idx * 32
    _fill_tile(img, idx, base_color)
    for i in range(80):
        img.set_pixel(
            offset + randi() % 32, randi() % 32, base_color.darkened(randf_range(0.05, 0.15))
        )


func _draw_craggy_stone(img: Image, idx: int, base_color: Color):
    var offset = idx * 32
    _fill_tile(img, idx, base_color)
    for i in range(6):
        var rx = randi() % 20
        var ry = randi() % 20
        for j in range(8):
            img.set_pixel(offset + rx + j, ry + j, base_color.darkened(0.2))


func _draw_painterly_grass(img: Image, idx: int, base_color: Color, seed_val: int):
    var offset = idx * 32
    seed(seed_val + 123)
    for x in range(32):
        for y in range(32):
            img.set_pixel(offset + x, y, base_color.lerp(base_color.darkened(0.05), randf()))
    for i in range(120):
        var rx = randi() % 32
        var ry = randi() % 31
        var bc = base_color.lightened(randf_range(0.05, 0.15))
        img.set_pixel(offset + rx, ry, bc)
        img.set_pixel(offset + rx, ry + 1, bc.darkened(0.2))


func _draw_stone_resource(img: Image, idx: int):
    var offset = idx * 32
    var base_color = Color(0.5, 0.5, 0.5)
    var shadow_color = Color(0.3, 0.3, 0.3)
    var highlight_color = Color(0.7, 0.7, 0.7)
    _draw_rect_custom(img, offset + 8, 14, 16, 12, base_color)
    _draw_rect_custom(img, offset + 10, 10, 12, 4, base_color)
    _draw_rect_custom(img, offset + 12, 8, 8, 2, base_color)
    for i in range(16):
        img.set_pixel(offset + 8 + i, 25, shadow_color)
        img.set_pixel(offset + 23, 14 + i if 14 + i < 26 else 25, shadow_color)
    for i in range(12):
        img.set_pixel(offset + 10 + i, 10, highlight_color)
    img.set_pixel(offset + 14, 15, shadow_color)
    img.set_pixel(offset + 15, 16, shadow_color)
    img.set_pixel(offset + 15, 17, shadow_color)
    img.set_pixel(offset + 19, 12, highlight_color)
    img.set_pixel(offset + 18, 11, highlight_color)


func _draw_clump(img: Image, idx: int, count: int, color: Color, size: int):
    var offset = idx * 32
    for i in range(count):
        _draw_rect_custom(img, offset + randi() % 28, randi() % 28, size, 1, color)


func _fill_tile(img: Image, idx: int, color: Color):
    _draw_rect_custom(img, idx * 32, 0, 32, 32, color)
