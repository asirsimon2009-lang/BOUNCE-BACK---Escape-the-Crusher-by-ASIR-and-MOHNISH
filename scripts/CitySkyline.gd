extends Node2D
# Procedurally drawn city skyline band with lit windows.

var building_color := Color(0, 0, 0, 0)
var window_color := Color(0, 0, 0, 0)
var tile_width := 780.0

var _rng_seed := 1
var _buildings: Array = []


func setup(seed_val: int) -> void:
	_rng_seed = seed_val
	_generate()


func _generate() -> void:
	_buildings.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng_seed
	var x := -40.0
	while x < tile_width:
		var w := rng.randf_range(26.0, 64.0)
		var h := rng.randf_range(50.0, 165.0)
		var windows: Array = []
		var cols := int(w / 9.0)
		var rows := int(h / 11.0)
		for c in cols:
			for r in rows:
				if rng.randf() < 0.32:
					windows.append(Vector2(
						x + 4.0 + c * 9.0,
						-h + 6.0 + r * 11.0
					))
		_buildings.append({
			"rect": Rect2(x, -h, w, h),
			"windows": windows,
			"antenna": rng.randf() < 0.22,
			"antenna_x": x + w * 0.5,
			"antenna_h": rng.randf_range(8.0, 26.0),
		})
		x += w + rng.randf_range(2.0, 10.0)
	queue_redraw()


func set_palette(b: Color, wcol: Color) -> void:
	if building_color.is_equal_approx(b) and window_color.is_equal_approx(wcol):
		return
	building_color = b
	window_color = wcol
	queue_redraw()


func _draw() -> void:
	if building_color.a <= 0.01:
		return
	# Rooftop ground strip the buildings stand on
	draw_rect(Rect2(-40, 0, tile_width + 80, 60), building_color)
	for b in _buildings:
		draw_rect(b.rect, building_color)
		if b.antenna:
			draw_line(
				Vector2(b.antenna_x, b.rect.position.y),
				Vector2(b.antenna_x, b.rect.position.y - b.antenna_h),
				building_color,
				2.0
			)
		for wpos in b.windows:
			draw_rect(Rect2(wpos, Vector2(3.0, 4.5)), window_color)
