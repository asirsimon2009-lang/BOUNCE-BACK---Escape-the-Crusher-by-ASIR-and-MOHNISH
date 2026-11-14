extends Node2D

const PLATFORM_SCENE := preload("res://scenes/platforms/Platform.tscn")
const COIN_SCENE := preload("res://scenes/coins/Coin.tscn")
const BOOSTER_SCENE := preload("res://scenes/boosters/Booster.tscn")

const LEVELS := [
	{
		"name": "SUNNY MEADOW", "height": 0, "theme": 0,
		"gap_min": 80.0, "gap_max": 125.0, "moving": 0.12, "breakable": 0.08, "coin_chance": 0.33,
	},
	{
		"name": "SUNSET PEAKS", "height": 100, "theme": 1,
		"gap_min": 88.0, "gap_max": 132.0, "moving": 0.22, "breakable": 0.16, "coin_chance": 0.30,
	},
	{
		"name": "STARRY NIGHT", "height": 200, "theme": 2,
		"gap_min": 96.0, "gap_max": 138.0, "moving": 0.32, "breakable": 0.24, "coin_chance": 0.27,
	},
	{
		"name": "NEON HEIGHTS", "height": 300, "theme": 3,
		"gap_min": 104.0, "gap_max": 145.0, "moving": 0.42, "breakable": 0.30, "coin_chance": 0.25,
	},
	{
		"name": "COSMIC DRIFT", "height": 400, "theme": 4,
		"gap_min": 110.0, "gap_max": 150.0, "moving": 0.48, "breakable": 0.34, "coin_chance": 0.22,
	},
	{
		"name": "VOLCANO FORGE", "height": 550, "theme": 5,
		"gap_min": 114.0, "gap_max": 154.0, "moving": 0.52, "breakable": 0.36, "coin_chance": 0.25,
	},
	{
		"name": "ARCTIC AURORA", "height": 700, "theme": 6,
		"gap_min": 118.0, "gap_max": 158.0, "moving": 0.55, "breakable": 0.38, "coin_chance": 0.28,
	},
	{
		"name": "QUANTUM MATRIX", "height": 850, "theme": 7,
		"gap_min": 122.0, "gap_max": 160.0, "moving": 0.58, "breakable": 0.40, "coin_chance": 0.30,
	},
]

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var platforms_node: Node2D = $Platforms
@onready var coins_node: Node2D = $Coins
@onready var background: Node2D = $Background
@onready var crusher: Area2D = $Crusher
@onready var sfx: Node = $SFX
@onready var menu: CanvasLayer = $Menu
@onready var hud: CanvasLayer = $HUD
@onready var score_label: Label = $HUD/Root/ScorePanel/HBox/ScoreLabel
@onready var best_label: Label = $HUD/Root/ScorePanel/HBox/BestLabel
@onready var coin_label: Label = $HUD/Root/ScorePanel/HBox/CoinGroup/CoinLabel
@onready var banner_root: Control = $HUD/Root/BannerRoot
@onready var banner_title: Label = $HUD/Root/BannerRoot/BannerTitle
@onready var banner_sub: Label = $HUD/Root/BannerRoot/BannerSub
@onready var warning_root: Control = $HUD/Root/WarningRoot
@onready var game_over_layer: CanvasLayer = $GameOver
@onready var game_over_root: Control = $GameOver/Root
@onready var cause_label: Label = $GameOver/Root/Panel/VBox/Cause
@onready var final_label: Label = $GameOver/Root/Panel/VBox/FinalScore
@onready var coins_final_label: Label = $GameOver/Root/Panel/VBox/Coins
@onready var best_final_label: Label = $GameOver/Root/Panel/VBox/BestScore
@onready var new_best_label: Label = $GameOver/Root/Panel/VBox/NewBest
@onready var restart_btn: Button = $GameOver/Root/Panel/VBox/Buttons/RestartBtn
@onready var menu_btn: Button = $GameOver/Root/Panel/VBox/Buttons/MenuBtn

var starting_height: float
var highest_height: float = 0.0
var game_over: bool = false
var game_started: bool = false
var coins_count: int = 0
var coin_points: int = 0
var level_index: int = 0
var _top_platform_y: float = 0.0
var _banner_tween: Tween
var _warning_tween: Tween
var _platforms_since_booster: int = 0
var _booster_status_label: Label

# Advanced Trauma-based Screen Shake Model
var _trauma: float = 0.0
const MAX_TRAUMA_OFFSET := Vector2(28.0, 22.0)
const MAX_TRAUMA_ROLL := 0.07  # ~4 degrees tilt


func _ready() -> void:
	starting_height = player.global_position.y
	highest_height = starting_height

	camera.enabled = true
	best_label.text = "BEST: " + str(GameState.best_score)

	_top_platform_y = _find_top_platform_y()
	for p in platforms_node.get_children():
		if p.has_signal("broken"):
			p.broken.connect(_on_platform_broken)
	for c in coins_node.get_children():
		if c.has_signal("collected"):
			c.collected.connect(_on_coin_collected)
	player.bounced.connect(sfx.play_bounce)
	player.booster_activated.connect(_on_booster_activated)
	_booster_status_label = Label.new()
	_booster_status_label.position = Vector2(14, 58)
	_booster_status_label.size = Vector2(450, 28)
	_booster_status_label.add_theme_font_size_override("font_size", 13)
	_booster_status_label.add_theme_color_override("font_color", Color(0.45, 0.95, 1.0, 1.0))
	_booster_status_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.1, 0.9))
	_booster_status_label.add_theme_constant_override("outline_size", 4)
	_booster_status_label.text = ""
	hud.get_node("Root").add_child(_booster_status_label)

	restart_btn.pressed.connect(_on_restart_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	menu.play_pressed.connect(_on_menu_play)
	menu.background_changed.connect(_on_background_changed)

	if crusher:
		crusher.setup(camera, starting_height + 450.0)
		crusher.player_crushed.connect(_on_player_crushed)
		crusher.proximity_warning.connect(_on_crusher_proximity)

	background.set_level(_current_theme_index())
	game_over_layer.visible = false
	hud.visible = false
	warning_root.visible = false
	player.is_game_active = false

	if GameState.skip_menu:
		GameState.skip_menu = false
		_start_game()
	else:
		menu.open()


func _start_game() -> void:
	menu.close()
	hud.visible = true
	player.is_game_active = true
	game_started = true
	if crusher:
		if GameState.crusher_enabled:
			crusher.activate()
		else:
			crusher.stop()
	_show_level_banner()


func _on_menu_play() -> void:
	sfx.play_click()
	_start_game()


func _on_background_changed(mode: int) -> void:
	GameState.set_bg_mode(mode)
	background.set_level(_current_theme_index())


func _on_restart_pressed() -> void:
	Engine.time_scale = 1.0
	GameState.skip_menu = true
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _current_theme_index() -> int:
	if GameState.bg_mode >= 0:
		return GameState.bg_mode
	return int(LEVELS[level_index]["theme"])


func _process(delta: float) -> void:
	_update_shake(delta)
	if Input.is_action_just_pressed("toggle_mute"):
		GameState.toggle_mute()
	if game_over:
		if Input.is_action_just_pressed("restart"):
			_on_restart_pressed()
		return
	if not game_started:
		return

	# Camera follows player upward smoothly
	if player.global_position.y < camera.global_position.y:
		camera.global_position.y = player.global_position.y

	# Calculate climbed height
	highest_height = minf(highest_height, player.global_position.y)
	var height_score = int((starting_height - highest_height) / 10.0)

	# Update crusher climb speed based on progress; slow-motion softens its chase.
	if crusher:
		crusher.update_difficulty(height_score)
		if player.slow_motion_active:
			crusher.current_speed *= 0.72

	if _booster_status_label:
		_booster_status_label.text = player.get_booster_status()

	# Advance levels
	while level_index + 1 < LEVELS.size() and height_score >= int(LEVELS[level_index + 1]["height"]):
		level_index += 1
		_on_level_entered()

	score_label.text = "SCORE: " + str(height_score + coin_points)

	# Procedural platform generation & culling
	_spawn_platforms_ahead()
	_cull_offscreen()

	# Detect falling below screen
	var screen_height := get_viewport_rect().size.y
	if player.global_position.y > camera.global_position.y + screen_height / 2.0 + 80.0:
		finish_game(false)


func _on_level_entered() -> void:
	background.set_level(_current_theme_index())
	sfx.play_level_up()
	_show_level_banner()


func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func _update_shake(delta: float) -> void:
	if _trauma > 0.0:
		_trauma = maxf(_trauma - delta * 1.5, 0.0)
		var shake := _trauma * _trauma  # Non-linear quadratic decay
		camera.offset = Vector2(
			randf_range(-1.0, 1.0) * MAX_TRAUMA_OFFSET.x * shake,
			randf_range(-1.0, 1.0) * MAX_TRAUMA_OFFSET.y * shake
		)
		camera.rotation = randf_range(-1.0, 1.0) * MAX_TRAUMA_ROLL * shake
	else:
		camera.offset = camera.offset.lerp(Vector2.ZERO, 0.35)
		camera.rotation = lerpf(camera.rotation, 0.0, 0.35)
		if camera.offset.length_squared() < 0.01:
			camera.offset = Vector2.ZERO
			camera.rotation = 0.0


func _show_level_banner() -> void:
	var lvl: Dictionary = LEVELS[level_index]
	banner_title.text = "LEVEL %d" % (level_index + 1)
	banner_sub.text = String(lvl["name"])
	if _banner_tween and _banner_tween.is_valid():
		_banner_tween.kill()
	banner_root.visible = true
	banner_root.modulate.a = 0.0
	_banner_tween = create_tween()
	_banner_tween.tween_property(banner_root, "modulate:a", 1.0, 0.35)
	_banner_tween.tween_interval(1.4)
	_banner_tween.tween_property(banner_root, "modulate:a", 0.0, 0.5)
	_banner_tween.tween_callback(_hide_banner)


func _hide_banner() -> void:
	banner_root.visible = false


func _on_crusher_proximity(is_near: bool) -> void:
	if is_near and not game_over:
		warning_root.visible = true
		sfx.play_alarm()
		if _warning_tween and _warning_tween.is_valid():
			_warning_tween.kill()
		_warning_tween = create_tween().set_loops()
		_warning_tween.tween_property(warning_root, "modulate:a", 1.0, 0.25)
		_warning_tween.tween_property(warning_root, "modulate:a", 0.2, 0.25)
	else:
		if _warning_tween and _warning_tween.is_valid():
			_warning_tween.kill()
		warning_root.visible = false


func _find_top_platform_y() -> float:
	var top := INF
	for p in platforms_node.get_children():
		top = minf(top, p.global_position.y)
	return top


func _spawn_platforms_ahead() -> void:
	var lvl: Dictionary = LEVELS[level_index]
	while _top_platform_y > camera.global_position.y - 720.0:
		var y := _top_platform_y - randf_range(float(lvl["gap_min"]), float(lvl["gap_max"]))
		var kind := _random_kind(float(lvl["moving"]), float(lvl["breakable"]))
		var x := randf_range(60.0, 420.0)
		if kind == 1:
			x = clampf(x, 120.0, 360.0)
		var p := PLATFORM_SCENE.instantiate()
		p.kind = kind
		p.position = Vector2(x, y)
		platforms_node.add_child(p)
		p.broken.connect(_on_platform_broken)
		_top_platform_y = y
		_platforms_since_booster += 1
		var spawned_booster := false
		# Guarantee a booster in each new themed section and then roughly every 4 platforms.
		var level_needs_booster := not bool(get_meta("booster_level_%d" % level_index, false))
		if level_needs_booster or _platforms_since_booster >= 4 or randf() < 0.10:
			var booster = BOOSTER_SCENE.instantiate()
			booster.kind = randi_range(0, 5)
			booster.position = Vector2(x, y - 48.0)
			add_child(booster)
			booster.collected.connect(_on_booster_collected)
			set_meta("booster_level_%d" % level_index, true)
			_platforms_since_booster = 0
			spawned_booster = true

		if not spawned_booster and randf() < float(lvl["coin_chance"]):
			var coin := COIN_SCENE.instantiate()
			coin.value = 20 + level_index * 5
			coin.position = Vector2(x, y - 42.0)
			coins_node.add_child(coin)
			coin.collected.connect(_on_coin_collected)


func _random_kind(moving_p: float, breakable_p: float) -> int:
	var r := randf()
	if r < moving_p:
		return 1
	if r < moving_p + breakable_p:
		return 2
	return 0


func _cull_offscreen() -> void:
	for p in platforms_node.get_children():
		if p.global_position.y > camera.global_position.y + 550.0:
			p.queue_free()
	for c in coins_node.get_children():
		if c.global_position.y > camera.global_position.y + 550.0:
			c.queue_free()
	for booster in get_tree().get_nodes_in_group("boosters"):
		if booster.global_position.y > camera.global_position.y + 550.0:
			booster.queue_free()


func _on_platform_broken() -> void:
	sfx.play_break()
	add_trauma(0.3)


func _on_coin_collected(value: int) -> void:
	coins_count += 1
	coin_points += value * (2 if player.score_multiplier_active else 1)
	coin_label.text = "x " + str(coins_count)
	sfx.play_coin()


func _on_booster_collected(_kind: int) -> void:
	add_trauma(0.12)


func _on_booster_activated(_kind: int, _duration: float) -> void:
	sfx.play_rocket()


func _on_player_crushed() -> void:
	if game_over:
		return
	finish_game(true)


func finish_game(was_crushed: bool) -> void:
	if game_over:
		return
	game_over = true
	player.set_game_over_state()

	if crusher:
		crusher.stop()
	if _warning_tween and _warning_tween.is_valid():
		_warning_tween.kill()
	warning_root.visible = false

	# Intense Camera Shake & Audio Impact
	if was_crushed:
		sfx.play_crush()
		add_trauma(1.0)
		cause_label.text = "CRUSHED BY THE HAZARD!"
		cause_label.modulate = Color(1.0, 0.35, 0.3)
		# Hitstop effect: brief freeze frame on impact
		_trigger_hitstop(0.08)
	else:
		sfx.play_game_over()
		add_trauma(0.8)
		cause_label.text = "FELL INTO THE ABYSS!"
		cause_label.modulate = Color(0.8, 0.85, 1.0)

	var height_score = int((starting_height - highest_height) / 10.0)
	var final_score = height_score + coin_points

	var is_new_best: bool = final_score > GameState.best_score
	if is_new_best:
		GameState.save_best(final_score)
		sfx.play_fanfare()

	final_label.text = "SCORE: " + str(final_score)
	coins_final_label.text = "COINS: " + str(coins_count)
	best_final_label.text = "BEST: " + str(GameState.best_score)
	new_best_label.visible = is_new_best

	hud.visible = false
	game_over_layer.visible = true
	var tween := create_tween()
	tween.tween_property(game_over_root, "modulate:a", 1.0, 0.28).from(0.0)


func _trigger_hitstop(duration: float) -> void:
	Engine.time_scale = 0.05
	var timer := get_tree().create_timer(duration * 0.05, true, false, true)
	timer.timeout.connect(func(): Engine.time_scale = 1.0)
