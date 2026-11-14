extends Node2D

const THEMES := [
	{
		"sky": [Color(0.40, 0.66, 0.95), Color(0.72, 0.85, 0.99), Color(0.93, 0.95, 1.0)],
		"stars": 0.0, "sun": 1.0,
		"cloud": Color(1, 1, 1, 0.8),
		"mtn_far": Color(0.62, 0.78, 0.68, 1), "mtn_near": Color(0.42, 0.63, 0.48, 1),
		"city_far_b": Color(0, 0, 0, 0), "city_far_w": Color(0, 0, 0, 0),
		"city_near_b": Color(0, 0, 0, 0), "city_near_w": Color(0, 0, 0, 0),
	},
	{
		"sky": [Color(0.36, 0.22, 0.45), Color(0.87, 0.47, 0.42), Color(1.0, 0.8, 0.55)],
		"stars": 0.15, "sun": 0.9,
		"cloud": Color(1.0, 0.86, 0.8, 0.55),
		"mtn_far": Color(0.42, 0.26, 0.42, 1), "mtn_near": Color(0.26, 0.15, 0.30, 1),
		"city_far_b": Color(0, 0, 0, 0), "city_far_w": Color(0, 0, 0, 0),
		"city_near_b": Color(0, 0, 0, 0), "city_near_w": Color(0, 0, 0, 0),
	},
	{
		"sky": [Color(0.03, 0.05, 0.14), Color(0.08, 0.11, 0.26), Color(0.16, 0.22, 0.42)],
		"stars": 0.85, "sun": 0.0,
		"cloud": Color(0.62, 0.68, 0.85, 0.25),
		"mtn_far": Color(0.14, 0.17, 0.32, 1), "mtn_near": Color(0.08, 0.10, 0.20, 1),
		"city_far_b": Color(0, 0, 0, 0), "city_far_w": Color(0, 0, 0, 0),
		"city_near_b": Color(0, 0, 0, 0), "city_near_w": Color(0, 0, 0, 0),
	},
	{
		"sky": [Color(0.03, 0.03, 0.10), Color(0.13, 0.06, 0.28), Color(0.30, 0.09, 0.34)],
		"stars": 0.35, "sun": 0.0,
		"cloud": Color(0.55, 0.42, 0.75, 0.10),
		"mtn_far": Color(0.10, 0.08, 0.22, 0), "mtn_near": Color(0.06, 0.05, 0.16, 0),
		"city_far_b": Color(0.16, 0.12, 0.34, 1), "city_far_w": Color(0.45, 1.0, 0.9, 0.85),
		"city_near_b": Color(0.07, 0.05, 0.16, 1), "city_near_w": Color(1.0, 0.42, 0.88, 0.95),
	},
	{
		"sky": [Color(0.02, 0.01, 0.06), Color(0.10, 0.04, 0.18), Color(0.22, 0.08, 0.30)],
		"stars": 1.0, "sun": 0.0,
		"cloud": Color(1, 1, 1, 0.0),
		"mtn_far": Color(0.13, 0.07, 0.20, 1), "mtn_near": Color(0.07, 0.04, 0.12, 1),
		"city_far_b": Color(0, 0, 0, 0), "city_far_w": Color(0, 0, 0, 0),
		"city_near_b": Color(0, 0, 0, 0), "city_near_w": Color(0, 0, 0, 0),
	},
	{
		"sky": [Color(0.12, 0.02, 0.02), Color(0.42, 0.08, 0.04), Color(0.85, 0.32, 0.08)],
		"stars": 0.25, "sun": 0.45,
		"cloud": Color(0.35, 0.18, 0.14, 0.55),
		"mtn_far": Color(0.26, 0.08, 0.06, 1), "mtn_near": Color(0.18, 0.04, 0.03, 1),
		"city_far_b": Color(0, 0, 0, 0), "city_far_w": Color(0, 0, 0, 0),
		"city_near_b": Color(0, 0, 0, 0), "city_near_w": Color(0, 0, 0, 0),
	},
	{
		"sky": [Color(0.02, 0.06, 0.14), Color(0.05, 0.24, 0.34), Color(0.15, 0.65, 0.55)],
		"stars": 0.95, "sun": 0.0,
		"cloud": Color(0.45, 0.85, 0.90, 0.35),
		"mtn_far": Color(0.08, 0.18, 0.28, 1), "mtn_near": Color(0.05, 0.12, 0.20, 1),
		"city_far_b": Color(0, 0, 0, 0), "city_far_w": Color(0, 0, 0, 0),
		"city_near_b": Color(0, 0, 0, 0), "city_near_w": Color(0, 0, 0, 0),
	},
	{
		"sky": [Color(0.01, 0.04, 0.02), Color(0.02, 0.14, 0.06), Color(0.06, 0.32, 0.12)],
		"stars": 0.6, "sun": 0.0,
		"cloud": Color(0.1, 0.5, 0.2, 0.18),
		"mtn_far": Color(0.02, 0.10, 0.04, 0), "mtn_near": Color(0.01, 0.06, 0.02, 0),
		"city_far_b": Color(0.02, 0.12, 0.05, 1), "city_far_w": Color(0.2, 1.0, 0.4, 0.9),
		"city_near_b": Color(0.01, 0.08, 0.03, 1), "city_near_w": Color(0.5, 1.0, 0.7, 0.95),
	},
]

var _level := 0
var _sky: Array = []
var _stars: float = 0.0
var _sun: float = 1.0
var _cloud := Color(1, 1, 1, 0.8)
var _mtn_far := Color(0.62, 0.78, 0.68, 1)
var _mtn_near := Color(0.42, 0.63, 0.48, 1)
var _city_far_b := Color(0, 0, 0, 0)
var _city_far_w := Color(0, 0, 0, 0)
var _city_near_b := Color(0, 0, 0, 0)
var _city_near_w := Color(0, 0, 0, 0)

@onready var sky: Sprite2D = $SkyLayer/Sky
@onready var stars: Node2D = $SkyLayer/Stars
@onready var sun: Node2D = $SkyLayer/Sun
@onready var clouds: Node2D = $SkyLayer/Clouds
@onready var motes: Node2D = get_node_or_null("SkyLayer/Motes")
@onready var mtn_far: Node2D = $MountainFar
@onready var mtn_near: Node2D = $MountainNear
@onready var city_far_a: Node2D = $CityFar/CityA
@onready var city_far_b: Node2D = $CityFar/CityB
@onready var city_near_a: Node2D = $CityNear/CityA
@onready var city_near_b: Node2D = $CityNear/CityB

var _gradient: Gradient


func _ready() -> void:
	_gradient = sky.texture.gradient
	for c in THEMES[0]["sky"]:
		_sky.append(c)
	clouds.modulate = _cloud
	mtn_far.modulate = _mtn_far
	mtn_near.modulate = _mtn_near
	_generate_clouds()
	_setup_city()


func set_level(idx: int) -> void:
	_level = clampi(idx, 0, THEMES.size() - 1)
	if motes:
		motes.set_theme(_level)


func _setup_city() -> void:
	city_far_a.setup(101)
	city_far_b.setup(101)
	city_near_a.setup(202)
	city_near_b.setup(202)
	_apply_city_palette()


func _apply_city_palette() -> void:
	city_far_a.set_palette(_city_far_b, _city_far_w)
	city_far_b.set_palette(_city_far_b, _city_far_w)
	city_near_a.set_palette(_city_near_b, _city_near_w)
	city_near_b.set_palette(_city_near_b, _city_near_w)


func _process(delta: float) -> void:
	var canvas: Transform2D = get_viewport().canvas_transform
	var cam_y: float = 360.0 - canvas.origin.y
	var time: float = Time.get_ticks_msec() / 1000.0
	_update_clouds(cam_y, time)
	_slide_layer(mtn_far, cam_y, 0.22, 580.8, 900.0)
	_slide_layer(mtn_near, cam_y, 0.45, 538.0, 860.0)
	_slide_layer($CityFar, cam_y, 0.18, 595.0, 900.0)
	_slide_layer($CityNear, cam_y, 0.38, 560.0, 860.0)
	_blend(delta)


func _blend(delta: float) -> void:
	var theme: Dictionary = THEMES[_level]
	var sky_colors: Array = theme["sky"]
	var w: float = 1.0 - exp(-delta * 3.0)
	for i in 3:
		_sky[i] = _sky[i].lerp(sky_colors[i], w)
		_gradient.set_color(i, _sky[i])
	_sun = lerpf(_sun, theme["sun"], w)
	sun.modulate.a = _sun
	_stars = lerpf(_stars, theme["stars"], w)
	stars.set_night(_stars)
	_cloud = _cloud.lerp(theme["cloud"], w)
	clouds.modulate = _cloud
	_mtn_far = _mtn_far.lerp(theme["mtn_far"], w)
	mtn_far.modulate = _mtn_far
	_mtn_near = _mtn_near.lerp(theme["mtn_near"], w)
	mtn_near.modulate = _mtn_near
	var city_changed := false
	_city_far_b = _city_far_b.lerp(theme["city_far_b"], w)
	_city_far_w = _city_far_w.lerp(theme["city_far_w"], w)
	_city_near_b = _city_near_b.lerp(theme["city_near_b"], w)
	_city_near_w = _city_near_w.lerp(theme["city_near_w"], w)
	_apply_city_palette()


func _generate_clouds() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 777
	for i in 7:
		var cloud := Node2D.new()
		var lobes := 3 + rng.randi() % 3
		for j in lobes:
			var r := rng.randf_range(9.0, 17.0)
			var lobe := Polygon2D.new()
			lobe.color = Color(1, 1, 1, 1)
			lobe.polygon = _circle_points(r)
			lobe.position = Vector2(
				(j - float(lobes - 1) * 0.5) * rng.randf_range(11.0, 15.0),
				-r * 0.25 + rng.randf_range(-2.0, 2.0)
			)
			cloud.add_child(lobe)
		cloud.position = Vector2(rng.randf_range(40.0, 440.0), rng.randf_range(40.0, 660.0))
		cloud.set_meta("base", cloud.position)
		cloud.set_meta("speed", rng.randf_range(5.0, 14.0))
		clouds.add_child(cloud)


func _circle_points(r: float, n: int = 12) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * float(i) / float(n)
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts


func _update_clouds(cam_y: float, time: float) -> void:
	for c in clouds.get_children():
		var base: Vector2 = c.get_meta("base")
		var speed: float = c.get_meta("speed")
		c.position = Vector2(
			fposmod(base.x + time * speed, 620.0) - 70.0,
			fposmod(base.y + cam_y * 0.15, 780.0) - 30.0
		)


func _slide_layer(layer: Node2D, cam_y: float, factor: float, phase: float, period: float) -> void:
	var base := cam_y * factor + phase
	var rel := base - cam_y
	while rel > 420.0:
		base -= period
		rel -= period
	layer.position.y = base
