shader_type canvas_item;

uniform float tolerance : hint_range(0.0, 1.0) = 0.1;
uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Warna Merah

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Cek apakah pixel ini berwarna merah (untuk baju)
	float dist = distance(tex_color.rgb, target_color.rgb);
	
	if (dist < tolerance && tex_color.a > 0.0) {
		// Gunakan COLOR.rgb (yang diset dari modulate) untuk mengganti warna baju
		// Ini memungkinkan Godot melakukan batching otomatis
		float brightness = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
		COLOR = vec4(COLOR.rgb * (brightness * 1.5), tex_color.a);
	} else {
		// Jika bukan baju, gunakan warna asli sprite tapi buang pengaruh modulate
		// agar kulit tidak ikut berubah warna
		COLOR = tex_color;
	}
}