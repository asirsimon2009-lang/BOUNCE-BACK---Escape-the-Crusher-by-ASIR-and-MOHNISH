# BOUNCE BACK – Escape the Crusher (Godot 4.7)

This project is an upgrade of the supplied original `doodle-jump` Godot project.
The original procedural platform gameplay, crusher chase, theme progression,
coins, score, background effects, game-over flow and generated SFX are retained.

## Run
1. Open this folder (`project.godot`) in Godot 4.7.
2. Allow Godot to import the PNG character assets.
3. Press F6 or F5 to run the game.

## Controls
- A / Left Arrow: move left
- D / Right Arrow: move right
- M: toggle sound
- R: restart after game over

## Added features
- BOUNCE BACK main menu branding.
- Dedicated character selection screen with all 20 supplied PNG characters.
- Character choice saved in `user://save.cfg` and restored on each run/restart.
- Player sprite is replaced at runtime while retaining the original CharacterBody2D
  collision body and bouncing physics.
- Six collectible boosters: Speed, Super Bounce, Shield, Magnet, Slow Motion, Score x2.
- Boosters are inserted into procedural platform generation, including a guaranteed
  booster spawn in each newly reached themed section and regular bonus spawns.
- Active booster names and remaining seconds appear in the HUD.
- Settings screen with master-volume slider and mute toggle.
- Original background theme and crusher options remain available.
- Original audio synthesis and sound effects are retained.

## Character assets
`assets/characters/` contains the 20 individually named transparent PNGs.
The sprites are trimmed to remove excess transparent padding and are sized for
consistent use with the original 44x44 collision body.

## Backup
`BACKUP/ORIGINAL_doodle-jump.zip` is the exact supplied original project archive.
The uploaded character ZIP is also included under `BACKUP/`.

## Verification status
Archive integrity, expected files, 20 character PNGs, scene references and key
script integrations were checked during packaging. A Godot executable was not
available in the build environment, so an actual engine launch/playtest could
not be performed here. Open in Godot 4.7 and run the project to complete runtime
verification.
