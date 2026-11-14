extends Node
# Persistent player preferences and high-score data.

const SAVE_PATH := "user://save.cfg"

var best_score: int = 0
var muted: bool = false
var master_volume: float = 0.8
var character_index: int = 0
var bg_mode: int = -1
var crusher_enabled: bool = true
var skip_menu: bool = false

const CHARACTER_FILES := [
	"01_Classic_Hero.png", "02_Fire_Ball.png", "03_Ice_Ball.png",
	"04_Nature_Ball.png", "05_Galaxy_Ball.png", "06_Pilot_Ball.png",
	"07_Robo_Ball.png", "08_Ninja_Ball.png", "09_Cat_Ball.png",
	"10_Panda_Ball.png", "11_Super_Ball.png", "12_King_Ball.png",
	"13_Angel_Ball.png", "14_Devil_Ball.png", "15_Pirate_Ball.png",
	"16_Wizard_Ball.png", "17_Pumpkin_Ball.png", "18_Lava_Ball.png",
	"19_Neon_Ball.png", "20_Rainbow_Ball.png"
]

const CHARACTER_NAMES := [
	"Classic Hero", "Fire Ball", "Ice Ball", "Nature Ball", "Galaxy Ball",
	"Pilot Ball", "Robo Ball", "Ninja Ball", "Cat Ball", "Panda Ball",
	"Super Ball", "King Ball", "Angel Ball", "Devil Ball", "Pirate Ball",
	"Wizard Ball", "Pumpkin Ball", "Lava Ball", "Neon Ball", "Rainbow Ball"
]


func _ready() -> void:
	_load()
	if OS.get_environment("DJ_SKIP_MENU") == "1":
		skip_menu = true
	apply_audio()


func get_character_path(index: int = -1) -> String:
	var selected := character_index if index < 0 else index
	selected = clampi(selected, 0, CHARACTER_FILES.size() - 1)
	return "res://assets/characters/" + CHARACTER_FILES[selected]


func select_character(index: int) -> void:
	character_index = clampi(index, 0, CHARACTER_FILES.size() - 1)
	_save()


func apply_audio() -> void:
	AudioServer.set_bus_mute(0, muted)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master_volume, 0.001)))


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_audio()
	_save()


func toggle_mute() -> bool:
	muted = not muted
	apply_audio()
	_save()
	return muted


func set_bg_mode(mode: int) -> void:
	bg_mode = mode
	_save()


func toggle_crusher() -> bool:
	crusher_enabled = not crusher_enabled
	_save()
	return crusher_enabled


func save_best(score: int) -> void:
	if score > best_score:
		best_score = score
		_save()


func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_score = int(cfg.get_value("scores", "best", 0))
		muted = bool(cfg.get_value("audio", "muted", false))
		master_volume = float(cfg.get_value("audio", "volume", 0.8))
		character_index = int(cfg.get_value("player", "character_index", 0))
		bg_mode = int(cfg.get_value("video", "bg_mode", -1))
		crusher_enabled = bool(cfg.get_value("gameplay", "crusher_enabled", true))
	character_index = clampi(character_index, 0, CHARACTER_FILES.size() - 1)
	master_volume = clampf(master_volume, 0.0, 1.0)


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("scores", "best", best_score)
	cfg.set_value("audio", "muted", muted)
	cfg.set_value("audio", "volume", master_volume)
	cfg.set_value("player", "character_index", character_index)
	cfg.set_value("video", "bg_mode", bg_mode)
	cfg.set_value("gameplay", "crusher_enabled", crusher_enabled)
	cfg.save(SAVE_PATH)
