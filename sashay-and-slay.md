# Sashay & Slay

A fabulous 2D fighting game where **Drag Queens** face off against **Politicians** in over-the-top combat!

## Game Concept

Think Mortal Kombat meets RuPaul's Drag Race meets C-SPAN. Each fighter has unique stats, special moves, and catchphrases. Rounds are best-of-3 with a 90-second timer.

## Roster

### Drag Queens
| Character | Special Move | Style |
|-----------|-------------|-------|
| **Glitterina** | Death Drop | Fast aerial attacker |
| **Lady Liberty** | Freedom Shade | Tanky brawler with knockback |
| **Miss Fire** | Flame Fatale | Glass cannon with AOE |
| **Anita Win** | Read to Filth | Ranged word projectiles |

### Politicians
| Character | Special Move | Style |
|-----------|-------------|-------|
| **Senator Stonewall** | Filibuster Fury | Slow tank with DOT |
| **Mayor McBudget** | Tax Attack | Balanced with rain projectiles |
| **Governor Gridlock** | Executive Disorder | Heavy hitter with stun |
| **Rep. Robocall** | Spam Slam | Fast spammer with multi-hit |

## Controls

### Player 1
- **Move**: WASD
- **Punch**: J
- **Kick**: K
- **Special**: L (when meter is full)
- **Block**: S (hold while on ground)

### Player 2
- **Move**: Arrow Keys
- **Punch**: Numpad 1
- **Kick**: Numpad 2
- **Special**: Numpad 3 (when meter is full)
- **Block**: Down Arrow (hold while on ground)

## Setup

1. Install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot and click "Import"
3. Navigate to this folder and select `project.godot`
4. Click "Import & Edit"
5. Press F5 to run!

## Project Structure

```
sashay-and-slay/
├── project.godot          # Godot project config
├── scenes/
│   ├── ui/                # Menu & character select scenes
│   ├── characters/        # Character scenes (to be created)
│   ├── stages/            # Stage/arena scenes (to be created)
│   └── fight.tscn         # Main fight scene
├── scripts/
│   ├── core/              # Game manager, fighter base, stage base
│   ├── characters/        # Individual character scripts
│   └── ui/                # Menu, HUD, character select
├── assets/
│   ├── sprites/           # Character, stage, and effect sprites
│   ├── audio/             # Music and sound effects
│   └── fonts/             # Custom fonts
└── resources/             # Godot resources (.tres files)
```

## Next Steps

- [ ] Create character sprites/animations
- [ ] Build out stage backgrounds (Runway Arena, Capitol Steps, etc.)
- [ ] Implement hitbox/hurtbox collision for combat
- [ ] Add sound effects and music
- [ ] Polish special move visual effects
- [ ] Add AI opponent for single player
- [ ] Victory/defeat screens with catchphrases
