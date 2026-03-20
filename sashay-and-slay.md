# Sashay & Slay

A fabulous 2D fighting game where **Drag Queens** face off against **Politicians** in over-the-top combat!

## Game Concept

Think Mortal Kombat meets RuPaul's Drag Race meets C-SPAN. Each fighter has unique stats, special moves, passives, and catchphrases. Rounds are best-of-3 with a 90-second timer.

## Game Modes

### Versus Mode
Local 2-player. Choose from all 15 queens and politicians (plus Don the Con once unlocked).

### Arcade Mode
Pick a drag queen and fight through all 7 politicians in random order on their home stages, then face Don the Con as the final boss. Completing arcade mode unlocks Don the Con for versus mode.

## Roster

### Drag Queens (8)
| Character | Special Move | Role |
|-----------|-------------|------|
| **Valencia Thunderclap** | 10s Across the Board | Counter-attacker |
| **Mama Molotov** | First Brick | Rage Tank |
| **Anita Riot** | No Justice No Peace | Rushdown Disruptor |
| **Dixie Normous** | The Library Is Open | Debuff Queen |
| **Siren St. James** | Miss Congeniality | Precision Striker |
| **Rex Hazard** | Daddy Issues | Grappler |
| **Thornia Rose** | Reclaiming My Thyme | Zone Controller |
| **Aurora Borealis** | Prismatic Judgment | Ranged Hybrid |

### Politicians (7)
| Character | Special Move | Role |
|-----------|-------------|------|
| **Ron DeSanctimonious** | Don't Say Slay | Culture Warrior |
| **Marjorie Trailer Queen** | Jewish Space Laser | Unhinged Rushdown |
| **Cancun Cruz** | Zodiac Filibuster | Coward Zoner |
| **Moscow Mitch** | Obstruct & Destroy | Pure Tank |
| **Elmo Musk** | Hostile Takeover | Tech Bro |
| **Mike Dense** | Conversion Therapy | Holy Warrior |
| **Greg Ablot** | Operation Lone Star | Trap Specialist |

### Unlockable Boss
| Character | Special Move | Role |
|-----------|-------------|------|
| **Don the Con** | Executive Disorder | Final Boss |

## Stages

| Stage | Home Fighter | Hazard |
|-------|-------------|--------|
| Book Ban Bonfire | Ron DeSanctimonious | Banned book projectiles (3 dmg, +10% damage buff) |
| The Supremely Cunty Court | Marjorie Trailer Queen | Gavel shockwave every 20s (5 dmg) |
| The Border Runway | Cancun Cruz | Spotlight dazzle debuff |
| The Fili-Buster Lounge | Moscow Mitch | Bass shockwave repositioning |
| Gerrymandered Gauntlet | Elmo Musk | Stage layout redraws every 20s |
| Pray Away the Slay | Mike Dense | Holy water slow every 25s |
| Mar-a-Lardo's Dinner Theatre | Greg Ablot | Classified document stun slides |
| Pride Float of War | (Versus only) | Float turning momentum push |
| The Gilded Throne Room | Don the Con (Boss) | FAKE NEWS screen obstruction at 25% HP |

## Controls

### Player 1
- **Move**: WASD
- **Punch**: J
- **Kick**: K
- **Special**: L (when meter is full)
- **Block**: S (hold while on ground)
- **Taunt**: T

### Player 2
- **Move**: Arrow Keys
- **Punch**: Numpad 1
- **Kick**: Numpad 2
- **Special**: Numpad 3 (when meter is full)
- **Block**: Down Arrow (hold while on ground)
- **Taunt**: Numpad 6

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
│   ├── ui/                # Main menu, character select, victory screen
│   ├── characters/        # Character scenes (to be created)
│   ├── stages/            # Stage/arena scenes (to be created)
│   └── fight.tscn         # Main fight scene with FightManager
├── scripts/
│   ├── core/              # GameManager, FightManager, Fighter, Stage,
│   │                      # RosterRegistry, ArcadeManager, StageRegistry,
│   │                      # InputManager, Projectile, BurningZone
│   ├── characters/        # 16 individual character scripts
│   ├── stages/            # 9 stage scripts with hazards
│   └── ui/                # Menu, HUD, character select, victory screen
├── assets/
│   ├── sprites/           # Character, stage, and effect sprites
│   ├── audio/             # Music and sound effects
│   └── fonts/             # Custom fonts
└── resources/             # Godot resources (.tres files)
```

## Architecture

### Game Flow
1. **Main Menu** — Versus or Arcade mode selection
2. **Character Select** — Roster from RosterRegistry, filtered by mode
3. **Fight Scene** — FightManager loads fighters and stage, wires signals
4. **Victory Screen** — Mode-specific result display, returns to menu

### Key Systems
- **RosterRegistry** — Central source of truth for all fighter data
- **ArcadeManager** — Tracks arcade progression, opponent queue, stage mapping
- **StageRegistry** — Maps politicians to home stages, stage keys to scripts
- **FightManager** — Orchestrates fight setup, round flow, and match transitions
- **InputManager** — Handles input scrambling, banning, and silencing
- **GameManager** — Global autoload for state, rounds, and persistence
