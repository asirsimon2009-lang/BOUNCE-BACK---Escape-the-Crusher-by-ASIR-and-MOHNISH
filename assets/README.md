# Assets

The game itself draws everything in code (Polygon2D / `_draw()` / synthesized audio),
so these files are **exports of that art** — useful for editing, other engines,
or swapping the procedural visuals for real textures.

## Contents

```
assets/
├── player/
│   ├── doodler.svg / doodler.png    # the green doodle character (matches Player.tscn)
├── platforms/
│   ├── platform_normal.svg / .png    # blue — standard
│   ├── platform_moving.svg / .png    # purple — slides side to side
│   └── platform_breakable.svg / .png # tan with cracks — crumbles after one bounce
├── coins/
│   └── coin.svg / coin.png           # spinning collectible
├── hazards/
│   └── crusher.png                   # industrial rising spiked hazard crusher
├── backgrounds/
│   └── cloud.svg / cloud.png         # one cloud (the game spawns clusters of these)
├── sounds/
│   ├── bounce.wav                    # landing "boing"
│   ├── break.wav                     # platform crumble
│   ├── coin.wav                      # pickup ding
│   ├── level_up.wav                  # level transition chime
│   ├── game_over.wav                 # falling sweep
│   ├── fall_thud.wav                 # low abyss drop impact
│   ├── crush.wav                     # crunchy industrial metal crush impact
│   ├── alarm.wav                     # pulsing proximity warning siren
│   ├── fanfare.wav                   # victory high score fanfare
│   └── click.wav                     # UI button click
└── player/, platforms/, coins/ PNGs are rendered at 2x game scale with transparency
```

`icon.svg` (project root) is the app icon.

## Regenerating

- **Sprites**: `powershell -File tools/make_assets.ps1` (edit colors/shapes in that script)
- **Sounds**: run the game once with the environment variable `DJ_EXPORT_ASSETS=1`,
  e.g. in PowerShell:
  ```
  $env:DJ_EXPORT_ASSETS = "1"
  & "C:\Users\LOQ\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path "C:\Users\LOQ\doodle-jump"
  ```
  This re-synthesizes every effect from `scripts/SFX.gd` and writes the WAVs, then exits.

## Using them in Godot

SVG and WAV files import natively. To switch, say, the player from Polygon2D parts to a
single texture: add a `Sprite2D` to `Player.tscn`, set its texture to
`res://assets/player/doodler.png` (scale 0.5, since the PNG is 2x), and hide/remove the
Polygon2D parts. The collision shape stays as-is.
