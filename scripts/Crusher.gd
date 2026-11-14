extends Area2D

signal player_crushed
signal proximity_warning(is_near: bool)

@export var base_speed: float = 40.0
@export var speed_scale_per_100m: float = 5.0
@export var max_speed: float = 180.0
@export var max_lag_from_camera: float = 720.0
@export var warning_threshold: float = 480.0

var is_active: bool = false
var current_speed: float = 40.0
var _time: float = 0.0
var _warning_active: bool = false
var _camera: Camera2D = null

@onready var teeth_container: Node2D = $Visual/Teeth
@onready var light_left: Polygon2D = $Visual/Frame/LightL
@onready var light_mid: Polygon2D = $Visual/Frame/LightM
@onready var light_right: Polygon2D = $Visual/Frame/LightR
@onready var sparks: CPUParticles2D = $Sparks
@onready var smoke: CPUParticles2D = $Smoke


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_build_procedural_teeth()


func setup(cam: Camera2D, start_y: float) -> void:
	_camera = cam
	global_position = Vector2(240.0, start_y)
	current_speed = base_speed
	is_active = false
	_warning_active = false


func activate() -> void:
	is_active = true
	sparks.emitting = true
	smoke.emitting = true


func stop() -> void:
	is_active = false
	sparks.emitting = false
	smoke.emitting = false


func update_difficulty(climbed_height_score: int) -> void:
	var bonus_speed := (float(climbed_height_score) / 100.0) * speed_scale_per_100m
	current_speed = clampf(base_speed + bonus_speed, base_speed, max_speed)


func _physics_process(delta: float) -> void:
	if not is_active:
		return

	_time += delta

	# Move upward steadily
	global_position.y -= current_speed * delta

	# Rubber-band: keep within maximum lag distance below camera
	if _camera:
		var max_allowed_y: float = _camera.global_position.y + max_lag_from_camera
		if global_position.y > max_allowed_y:
			global_position.y = lerpf(global_position.y, max_allowed_y, 0.08)

		# Check distance to camera for proximity warning
		var dist_to_camera := global_position.y - _camera.global_position.y
		var near := dist_to_camera < warning_threshold
		if near != _warning_active:
			_warning_active = near
			proximity_warning.emit(_warning_active)

	_animate(delta)


func _animate(_delta: float) -> void:
	# Animate chewing hydraulic teeth
	if teeth_container:
		var chew_y := sin(_time * 9.0) * 4.5
		var chew_x := cos(_time * 4.5) * 2.0
		teeth_container.position = Vector2(chew_x, chew_y)

	# Alternate pulsing hazard beacon lights
	var blink_a := (sin(_time * 8.0) + 1.0) * 0.5
	var blink_b := (cos(_time * 8.0) + 1.0) * 0.5
	if light_left:
		light_left.color = Color(1.0, 0.2, 0.15, 0.35 + 0.65 * blink_a)
	if light_mid:
		light_mid.color = Color(1.0, 0.85, 0.1, 0.4 + 0.6 * blink_b)
	if light_right:
		light_right.color = Color(1.0, 0.2, 0.15, 0.35 + 0.65 * blink_a)


func _build_procedural_teeth() -> void:
	if teeth_container.get_child_count() > 0:
		return
	# Generate 11 steel grinding spikes across the width (x = -240 to +240)
	var count := 11
	var spacing := 480.0 / float(count)
	for i in count:
		var tooth := Polygon2D.new()
		var cx := -240.0 + spacing * (float(i) + 0.5)
		var half_w := spacing * 0.52
		var height := 26.0 if i % 2 == 0 else 32.0
		tooth.polygon = PackedVector2Array([
			Vector2(cx - half_w, 0.0),
			Vector2(cx, -height),
			Vector2(cx + half_w, 0.0)
		])
		# Steel gradient coloring with dark outline
		tooth.color = Color(0.85, 0.88, 0.94, 1.0) if i % 2 == 0 else Color(0.72, 0.76, 0.82, 1.0)
		teeth_container.add_child(tooth)

		# Highlight bevel on the left face of the tooth
		var bevel := Polygon2D.new()
		bevel.polygon = PackedVector2Array([
			Vector2(cx - half_w, 0.0),
			Vector2(cx, -height),
			Vector2(cx, 0.0)
		])
		bevel.color = Color(1.0, 1.0, 1.0, 0.28)
		tooth.add_child(bevel)


func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	if body.has_method("set_game_over_state"):
		if body.has_method("consume_shield") and body.consume_shield():
			# Shield absorbs one crusher contact and knocks the player upward.
			var knockback: Vector2 = body.get("velocity")
			knockback.y = -520.0
			knockback.x = randf_range(-180.0, 180.0)
			body.set("velocity", knockback)
			sparks.amount = 24
			sparks.restart()
			return
		# Crunch effect!
		sparks.amount = 40
		sparks.restart()
		player_crushed.emit()
