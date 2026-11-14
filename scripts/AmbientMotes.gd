extends Node2D
# Ambient atmospheric motes, floating pollen, embers, cyber rain, and cosmic stardust.

var current_theme: int = 0
var _particles: Array = []
var _time: float = 0.0

const PARTICLE_COUNT := 35


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 98765
	for i in PARTICLE_COUNT:
		_particles.append({
			"pos": Vector2(rng.randf_range(0.0, 480.0), rng.randf_range(0.0, 720.0)),
			"size": rng.randf_range(1.5, 3.5),
			"speed": rng.randf_range(12.0, 36.0),
			"sway": rng.randf_range(1.0, 3.0),
			"phase": rng.randf_range(0.0, TAU),
			"alpha": rng.randf_range(0.35, 0.85),
		})


func set_theme(idx: int) -> void:
	current_theme = clampi(idx, 0, 7)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	for p in _particles:
		match current_theme:
			0:  # Meadow pollen
				p.pos.x += delta * (p.speed * 0.7)
				p.pos.y += sin(_time * p.sway + p.phase) * delta * 15.0 - delta * 8.0
			1:  # Sunset embers (float upwards)
				p.pos.x += sin(_time * p.sway + p.phase) * delta * 12.0
				p.pos.y -= delta * (p.speed * 0.85)
			2:  # Night fireflies (gentle hover)
				p.pos.x += cos(_time * p.sway * 0.7 + p.phase) * delta * 10.0
				p.pos.y += sin(_time * p.sway + p.phase) * delta * 10.0
			3:  # Cyber rain (fast downward streaks)
				p.pos.y += delta * (p.speed * 4.5 + 80.0)
				p.pos.x += delta * 10.0
			4:  # Cosmic dust (slow multidirectional drift)
				p.pos.x += cos(_time * 0.4 + p.phase) * delta * 8.0
				p.pos.y += sin(_time * 0.4 + p.phase) * delta * 8.0
			5:  # Volcano embers (fast rising fiery sparks)
				p.pos.x += sin(_time * p.sway * 1.5 + p.phase) * delta * 24.0
				p.pos.y -= delta * (p.speed * 1.8 + 45.0)
			6:  # Arctic frost crystals (gentle fluttering snowfall)
				p.pos.x += cos(_time * p.sway + p.phase) * delta * 18.0
				p.pos.y += delta * (p.speed * 0.65 + 15.0)
			7:  # Matrix digital code stream (vertical high-speed green flow)
				p.pos.y += delta * (p.speed * 5.5 + 110.0)
				p.pos.x += sin(p.phase) * 1.5

		# Wrap around screen bounds
		if p.pos.x < -10.0:
			p.pos.x = 490.0
		elif p.pos.x > 490.0:
			p.pos.x = -10.0
		if p.pos.y < -10.0:
			p.pos.y = 730.0
		elif p.pos.y > 730.0:
			p.pos.y = -10.0

	queue_redraw()


func _draw() -> void:
	for p in _particles:
		var pulse: float = 0.75 + 0.25 * sin(_time * 3.0 + p.phase)
		var a: float = p.alpha * pulse
		match current_theme:
			0:  # Soft white/gold dandelion pollen
				draw_circle(p.pos, p.size, Color(1.0, 0.98, 0.88, a * 0.55))
				draw_circle(p.pos, p.size * 0.5, Color(1.0, 1.0, 1.0, a * 0.8))
			1:  # Golden warm embers
				draw_circle(p.pos, p.size, Color(1.0, 0.6, 0.2, a * 0.7))
				draw_circle(p.pos, p.size * 0.5, Color(1.0, 0.9, 0.5, a * 0.9))
			2:  # Soft bioluminescent fireflies
				draw_circle(p.pos, p.size * 1.5, Color(0.4, 0.9, 1.0, a * 0.2))
				draw_circle(p.pos, p.size * 0.7, Color(0.8, 1.0, 0.9, a * 0.8))
			3:  # Neon data rain streaks
				var col := Color(0.1, 0.95, 0.85, a * 0.75) if int(p.phase * 10.0) % 2 == 0 else Color(1.0, 0.25, 0.85, a * 0.75)
				draw_line(p.pos, p.pos + Vector2(2.0, p.size * 4.0), col, 1.5)
			4:  # Cosmic stardust
				var star_col := Color(0.7, 0.5, 1.0, a * 0.8) if int(p.phase * 5.0) % 2 == 0 else Color(0.4, 0.8, 1.0, a * 0.8)
				draw_circle(p.pos, p.size * 1.3, Color(star_col.r, star_col.g, star_col.b, a * 0.25))
				draw_circle(p.pos, p.size * 0.6, Color(1.0, 1.0, 1.0, a * 0.9))
			5:  # Volcano embers (fiery orange/crimson with bright yellow hot core)
				draw_circle(p.pos, p.size * 1.6, Color(1.0, 0.25, 0.05, a * 0.45))
				draw_circle(p.pos, p.size * 0.7, Color(1.0, 0.85, 0.2, a * 0.95))
			6:  # Arctic frost/aurora crystals (shimmering diamond flakes)
				var aurora_c := Color(0.2, 0.95, 0.85, a * 0.8) if int(p.phase * 3.0) % 2 == 0 else Color(0.65, 0.45, 1.0, a * 0.75)
				draw_circle(p.pos, p.size * 1.4, Color(aurora_c.r, aurora_c.g, aurora_c.b, a * 0.3))
				draw_circle(p.pos, p.size * 0.6, Color(1.0, 1.0, 1.0, a * 0.95))
			7:  # Matrix phosphor digital glyph lines
				var line_col := Color(0.15, 1.0, 0.35, a * 0.9)
				draw_line(p.pos, p.pos + Vector2(0.0, p.size * 5.0 + 3.0), line_col, 2.0)
				draw_circle(p.pos, 1.5, Color(0.8, 1.0, 0.85, a * 0.95))
