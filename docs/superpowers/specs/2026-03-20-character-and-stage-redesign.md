# Sashay & Slay — Character & Stage Redesign

## Overview

Complete redesign of the Sashay & Slay roster and stages. The game is a 2D fighting game (Godot 4.2) where drag queens save the world from thinly-veiled satirical versions of real American politicians. Maximum satirical edge. No holding back.

## Game Structure

- **Roster:** 8 drag queen heroes vs 7 selectable politicians + 1 unlockable final boss
- **Arcade Mode:** Pick a queen, fight through all 7 politicians in sequence, then face Don the Con as the final boss
- **Versus Mode:** Local 2-player. All queens + 7 politicians available. Don the Con unlocked after completing arcade mode
- **Rounds:** Best of 3, 90-second timer
- **Engine:** Godot 4.2, 2D
- **No ring-outs:** Fighters cannot be knocked off the stage. Arena walls are solid boundaries.

## Stat Glossary

| Stat | Unit | Description |
|------|------|-------------|
| **HP** | Hit points | Total health. Reduced by incoming damage (after block reduction). Fighter is KO'd at 0. |
| **Speed** | Pixels/second | Walk speed. Higher = faster lateral movement. |
| **Punch** | Damage per hit | Base damage dealt by punch attacks. |
| **Kick** | Damage per hit | Base damage dealt by kick attacks. |
| **Special** | Damage | Total base damage dealt by special move. For multi-hit specials, per-hit values listed in the move description are the final damage numbers (not fed back into the formula). |

### Damage Formula

```
# For punch and kick attacks:
final_damage = base_damage * move_multiplier * stat_modifier
  - base_damage = Punch or Kick stat
  - move_multiplier = 1.0 (normal), 1.5x (Ego Meter buff), 0.2x (blocked)
  - stat_modifier = 1.0 default, reduced by Dixie's reads (stacks of -10% per read, min 0.5x)

# For special moves:
  - Use the per-hit damage values listed in each move description directly
  - These are final values (already account for the Special stat)
  - Block multiplier (0.2x) still applies unless the move is unblockable
  - Dixie's stat_modifier still applies
```

### Projectile Rules

- All projectiles travel at 400 pixels/second unless otherwise noted
- Projectiles can be blocked (80% reduction) unless labeled "unblockable"
- Projectiles cannot be destroyed by attacks (they pass through)
- Projectiles do not collide with each other
- Stage hazard projectiles follow their own rules (specified per hazard)

### Taunt

- Input: dedicated taunt button (not mapped to attack inputs)
- Duration: 1 second animation, fighter is vulnerable during taunt
- Used by: Dixie (heal on read), Don the Con (ego build), Elmo Musk (Capital spend menu via taunt + direction)

### Special Meter

- Meter range: 0–100
- Dealing damage builds meter: `+damage_dealt * 0.4`
- Taking damage builds meter: `+damage_taken * 0.5`
- Full meter (100) = special move available. Meter resets to 0 on use.

### Round Reset Rules

All per-round effects reset between rounds:
- Dixie's stat reductions reset
- Thornia's planted thorns are cleared
- Mama Molotov's Riot Mode resets (based on new round HP)
- Rex Hazard's grab range resets
- Ron DeSanctimonious's banned moves reset
- Don the Con's Ego Meter resets
- Moscow Mitch's obstruction meter resets
- Elmo Musk's Capital resets to 50
- All debuffs (slows, input scrambles, silences) clear

## Fighter Mechanics

- **Passive abilities** — Every fighter has a unique passive that shapes their playstyle
- **Special meter** — Builds from dealing AND taking damage. Full meter = special move available
- **Block system** — Holding down while grounded reduces incoming damage by 80% (0.2x multiplier)
- **Character-specific resources** — Some fighters have secondary meters (Mama Molotov's Riot Mode at 30% HP, Don the Con's Ego Meter)
- **Stat degradation** — Dixie Normous can permanently reduce opponent stats per round (stacking -10% per read, min 0.5x)
- **Input disruption** — Anita Riot and Ron DeSanctimonious can scramble/disable opponent controls
- **Stage hazards** — Every stage has a unique environmental mechanic
- **Knockback resistance** — Heavier fighters (higher HP) have proportionally more knockback resistance. Formula: `knockback_modifier = 100 / fighter_HP`

---

## Drag Queen Roster (Heroes)

### 1. Valencia Thunderclap
- **Archetype:** Ballroom Mother / Vogue Assassin
- **Style:** Counter-attacker who dodges through dips, duckwalks, and spins. Every dodge builds combo meter. The more they miss, the harder she hits back. Untouchable when played well.
- **Special — "10s Across the Board"** (35 dmg) — Time freezes. She vogues through a 5-hit combo (7 dmg each), each pose scored by phantom judges. Player must hit timed inputs for each pose. All 5 perfect = bonus 15 dmg (50 total). Miss any = that hit deals 0.
- **Passive — "The Floor is Yours"** — Dodging 3 attacks in a row triggers a free death drop counter-attack (15 dmg, unblockable).
- **Catchphrase:** "You're giving me nothing to work with, and I'm still serving everything."
- **Stats:** HP 95 | Speed 340 | Punch 6 | Kick 8 | Special 35

### 2. Mama Molotov
- **Archetype:** Stonewall Veteran / Rage Tank
- **Style:** Brawler who gets more dangerous as she takes damage. Below 30% health she enters "Riot Mode" — speed +30%, punch/kick +40%, heavy attacks become unblockable. She doesn't retreat. Ever.
- **Special — "First Brick"** (30 dmg) — Unblockable projectile that explodes on impact, leaving a burning zone (3 dmg/second for 8 seconds, 24 max DOT) that denies ground.
- **Passive — "We Were Always Here"** — Takes 20% reduced knockback (stacks with her high HP knockback resistance). The wall is not her enemy — her opponents are.
- **Catchphrase:** "I've been fighting fascists since before you were a fundraising email."
- **Stats:** HP 130 | Speed 260 | Punch 11 | Kick 13 | Special 30

### 3. Anita Riot
- **Archetype:** Punk Protest Queen / Disruptor
- **Style:** Rushdown who thrives in chaos. She doesn't fight fair because the system never did.
- **Special — "No Justice No Peace"** (28 dmg) — Megaphone shockwave (8 dmg, pushes to wall) followed by a crowd-surge rush of phantom protesters (4 hits × 5 dmg each).
- **Passive — "Disruption"** — Every 4th hit scrambles one random opponent input for 3 seconds (e.g., left becomes right, punch becomes kick).
- **Catchphrase:** "Your comfort was built on our silence. Sound check's over."
- **Stats:** HP 90 | Speed 350 | Punch 8 | Kick 9 | Special 28

### 4. Dixie Normous
- **Archetype:** Southern Comedy Queen / Psychological Warfare
- **Style:** Debuff queen who dismantles opponents piece by piece. Kick attacks are "reads" — each successful read permanently reduces a random opponent stat by 10% for the round (min 0.5x). By late fight, the opponent is a shell of themselves.
- **Special — "The Library Is Open"** (22 dmg) — 5-hit combo (4 dmg + 4 dmg + 4 dmg + 4 dmg + 6 dmg), each hit applies a -10% stat reduction. Final hit drains opponent's special meter to 0.
- **Passive — "Bless Your Heart"** — Taunting (press taunt button) after a successful read heals Dixie for 5 HP.
- **Catchphrase:** "Oh honey, I'm not being mean. The truth just hurts when it's this well-accessorized."
- **Stats:** HP 100 | Speed 290 | Punch 7 | Kick 8 | Special 22

### 5. Siren St. James
- **Archetype:** Pageant Assassin / Ice Queen
- **Style:** Slow, devastating precision. Every attack has wind-up but hits like a freight train in heels. Walk speed is a runway strut. She never rushes — she arrives.
- **Special — "Miss Congeniality"** (32 dmg) — Blows a kiss projectile that stuns for 1.5 seconds, then charges with a razor-edged scepter for a 3-hit combo (8 + 10 + 14 dmg).
- **Passive — "Poise Under Pressure"** — Standing still for 2 seconds grants super armor on her next attack (absorbs one hit without flinching). Rewards patience.
- **Catchphrase:** "I'd wish you luck, but it won't help."
- **Stats:** HP 105 | Speed 240 | Punch 12 | Kick 14 | Special 32

### 6. Rex Hazard
- **Archetype:** Drag King / Leather Daddy Grappler
- **Style:** Command grab specialist. Gets in your face, picks you up, puts you down. Hard. Every grab leads to a different slam depending on position (wall slam near walls, suplex mid-stage, aerial spike in air).
- **Special — "Daddy Issues"** (30 dmg) — Unblockable grab (range: 60px base). Picks opponent up, headbutts (10 dmg), then pile-drives them (20 dmg). Camera shakes.
- **Passive — "Masc 4 Massacre"** — Each successful grab increases grab range by 10px for the rest of the round (base 60px, max 120px).
- **Catchphrase:** "I'm not your daddy. But I am your problem."
- **Stats:** HP 115 | Speed 270 | Punch 10 | Kick 11 | Special 30

### 7. Thornia Rose
- **Archetype:** Bearded Queen / Eco-Witch / Zone Controller
- **Style:** Area denial. Plants thorns (kick places a thorn at current position), grows vines, poisons the ground. Forces opponents into smaller and smaller safe zones. Max 5 thorns active at once.
- **Special — "Reclaiming My Thyme"** (25 dmg) — Vines erupt across the full stage, grabbing the opponent (rooted 3 seconds) while poisonous flowers bloom. DOT: 5 dmg/second for 5 seconds.
- **Passive — "Overgrowth"** — Planted thorns grow each second: 2 dmg on contact at 0-3s, 4 dmg at 3-6s, 6 dmg at 6s+. Ignoring them is punished.
- **Catchphrase:** "Nature doesn't negotiate. Neither do I."
- **Stats:** HP 100 | Speed 280 | Punch 7 | Kick 9 | Special 25

### 8. Aurora Borealis
- **Archetype:** Cosmic Nonbinary Queen / Light Wielder
- **Style:** Ranged hybrid with self-sustain. Floaty double-jump, light beam zoning (punch fires a short beam projectile), and sustain that makes them the best war-of-attrition fighter.
- **Special — "Prismatic Judgment"** (28 dmg) — Ascends above the stage. Six rainbow beams converge on opponent's position, exploding for 28 dmg. Heals Aurora for 20% of damage dealt (5-6 HP).
- **Passive — "Spectral Shield"** — Taking 30 total damage charges a light shield. Next hit is absorbed completely (0 damage) and reflected as a rainbow projectile (8 dmg).
- **Catchphrase:** "You tried to erase us from the sky. Look up."
- **Stats:** HP 95 | Speed 300 | Punch 6 | Kick 7 | Special 28

---

## Politician Roster (Villains)

### 1. Ron DeSanctimonious
- **Inspired by:** Florida's book-banning governor
- **Style:** Culture warrior. Every 15 seconds, he bans one of the opponent's moves (random: punch or kick only — block cannot be banned). Banned moves do nothing when pressed. Max 2 bans active; oldest ban expires when a third is applied.
- **Special — "Don't Say Slay"** (0 dmg, utility) — Issues a ban wave that silences the opponent completely for 4 seconds — no attacks, no specials, no blocking. Just standing there. DeSanctimonious can attack freely during silence.
- **Passive — "Parental Advisory"** — When opponent uses their special move, DeSanctimonious gains 15% damage reduction for 5 seconds ("this content has been flagged").
- **Catchphrase:** "This fight has been deemed inappropriate for all audiences."
- **Stats:** HP 110 | Speed 280 | Punch 9 | Kick 10 | Special 0 (utility special, no damage)

### 2. Marjorie Trailer Queen
- **Inspired by:** Georgia's conspiracy congresswoman
- **Style:** Unhinged rushdown. Wild, erratic attacks. 20% chance on any attack to deal 1.5x damage (conspiracy energy). 10% chance to hit herself instead for 50% of the attack's damage.
- **Special — "Jewish Space Laser"** (30 dmg) — Tracking laser from the sky hits opponent for 30 dmg. Also ignites the ground beneath both fighters — burning zone deals 4 dmg/second for 4 seconds to anyone standing in it (including Marjorie).
- **Passive — "Do Your Own Research"** — After being knocked down, gets back up 30% faster and her next attack has guaranteed 1.5x damage. Chaos rewards chaos.
- **Catchphrase:** "I did my own research! On Facebook!"
- **Stats:** HP 95 | Speed 330 | Punch 9 | Kick 11 | Special 30

### 3. Cancun Cruz
- **Inspired by:** Texas's fleeing senator
- **Style:** Coward archetype. Runs away and attacks from distance with projectile attacks (thrown briefcases). Has a "flee" dash (invincible for 0.5 seconds, travels half-stage distance). Deals 25% bonus damage to opponents below 40% HP (kicks them while they're down).
- **Special — "Zodiac Filibuster"** (26 dmg) — Reads Green Eggs and Ham, creating a sleep zone (120px radius, grows to 200px over 2 seconds) around him. Opponent caught in it falls asleep for 2 seconds, then Cruz smashes them with a suitcase (26 dmg).
- **Passive — "Fled the State"** — When Cruz drops below 30% HP, his flee dash cooldown is halved and he gains +20% speed. Running is what he does best.
- **Catchphrase:** "I'd love to fight, but I have a flight to catch."
- **Stats:** HP 100 | Speed 310 | Punch 7 | Kick 8 | Special 26

### 4. Moscow Mitch
- **Inspired by:** The Senate's eternal obstructionist
- **Style:** Pure tank/stall. Extremely slow but near-impossible to kill. Wins by timeout. Has a secondary "obstruction meter" that builds while blocking — at full meter, his next attack does 2x damage.
- **Special — "Obstruct & Destroy"** (20 dmg + stored) — Enters a 100% damage immunity shell for 4 seconds. All damage that would have been dealt is stored. When immunity ends, releases stored damage + 20 base as a shockwave.
- **Passive — "Table the Motion"** — Blocking builds his obstruction meter. At full meter (blocked 40 total damage), his next attack deals 2x damage and is unblockable. Meter resets after use.
- **Catchphrase:** "The motion to defeat me... is tabled."
- **Stats:** HP 140 | Speed 200 | Punch 8 | Kick 9 | Special 20

### 5. Elmo Musk
- **Inspired by:** The world's richest edge-lord
- **Style:** Tech bro with gadgets. Has a "Capital" resource (starts at 50, max 100). Gains 1 Capital per second. Can spend Capital mid-fight: 15 = deploy attack drone (fires 3 shots of 4 dmg each, 10 HP, lasts 8 seconds), 25 = shield drone (blocks next hit, 1 HP, lasts 10 seconds), 40 = satellite strike (targeted AOE, 15 dmg). Max 2 drones active at once.
- **Special — "Hostile Takeover"** (28 dmg) — Costs 0 Capital. Opponent stumbles (stun 1 second), stage floor becomes electric (2 dmg/second for 6 seconds). On stages with platforms, platforms disappear for 6 seconds then return to their pre-special positions.
- **Passive — "Move Fast Break Things"** — When the opponent destroys one of his drones, Musk is refunded 150% of that drone's Capital cost. Musk cannot destroy his own drones.
- **Catchphrase:** "I'm not a villain. I'm a disruptor. Same thing."
- **Stats:** HP 100 | Speed 290 | Punch 7 | Kick 8 | Special 28

### 6. Mike Dense
- **Inspired by:** The vice president who calls his wife "Mother"
- **Style:** Holy warrior. Has a "pray" stance (hold block + up) that charges power — after 3 seconds of praying, next attack deals 2x damage and has a holy glow effect. Summons "Mother" — a ghostly NPC that follows him and auto-blocks one attack every 10 seconds (cosmetically a stern woman shaking her head).
- **Special — "Conversion Therapy"** (24 dmg) — Grabs opponent in a prayer circle. Deals 24 dmg, reverses their controls for 4 seconds, and drains 30 special meter.
- **Passive — "Mother Knows Best"** — "Mother" NPC auto-blocks one incoming attack every 10 seconds. The block absorbs all damage from that single hit. She then disappears for 10 seconds before returning.
- **Catchphrase:** "Mother wouldn't approve of this."
- **Stats:** HP 105 | Speed 270 | Punch 9 | Kick 10 | Special 24

### 7. Greg Ablot
- **Inspired by:** The Texas governor who pulled up the ladder
- **Style:** Trap specialist. Kick places a barrier (max 3 active). Barriers are stage obstacles — opponents collide with them and take 5 dmg on contact. Barriers have 15 HP and can be destroyed.
- **Special — "Operation Lone Star"** (26 dmg) — National Guard rush across the stage left-to-right (4 hits × 6.5 dmg each), pushing the opponent into the nearest barrier/wall. If opponent hits a barrier, bonus 8 dmg.
- **Passive — "Pulled Up the Ladder"** — Greg takes 30% reduced damage while standing behind one of his own barriers. Safety through walls.
- **Catchphrase:** "This stage is CLOSED."
- **Stats:** HP 110 | Speed 260 | Punch 9 | Kick 11 | Special 26

---

## Unlockable Final Boss

### Don the Con
- **Inspired by:** The former guy. Orange. Gold. Tremendous.
- **Unlock condition:** Complete arcade mode (defeat all 7 politicians + Don the Con)
- **Style:** Overpowered final boss. Slow, tanky, massive ego meter. Attacks with gold-plated everything. 1.3x larger sprite than other fighters.
- **Ego Meter:** Secondary resource (0–100). Builds +5 when he lands an attack, +10 when he taunts. At 100, enters "Tremendous Mode" for 8 seconds: all attacks do 1.5x damage, gains super armor. Taking damage drains ego by the damage amount. Tremendous Mode lasts the full 8 seconds regardless of ego drain (ego can go negative during it, but won't trigger again until rebuilt to 100).
- **Special — "Executive Disorder"** (35 dmg) — Signs a flurry of executive orders that rain as 7 projectiles (5 dmg each). Each projectile hit bans a random opponent input for 5 seconds.
- **Passive — "Fake It Till You Make It"** — Don the Con's taunt is 50% faster than other fighters (0.5 seconds vs 1 second), letting him build Ego Meter more aggressively.
- **Phase 2 (at 40% HP):** "You're fired!" — Stage transforms (background changes, dramatic lighting). Attack speed increases 20%. Tweets fly across the screen from alternating sides (left, then right) every 3 seconds as additional projectiles (4 dmg each, 500 px/sec, blockable). Phase 2 is permanent once triggered.
- **Boss Stage Hazard Interaction:** Phase 2 triggers at 40% HP. The "big red button" FAKE NEWS banners trigger at 25% HP (during Phase 2). They stack — Phase 2 is active while FAKE NEWS banners obscure 20% of the screen.
- **Catchphrase:** "Nobody fights like me. Everybody says so. Tremendous fighter."
- **Exclusive Stage:** The Gilded Throne Room
- **Stats:** HP 160 | Speed 230 | Punch 12 | Kick 14 | Special 35

---

## Stage–Fighter Mapping (Arcade Mode)

| Politician | Home Stage |
|-----------|-------|
| Ron DeSanctimonious | Book Ban Bonfire |
| Marjorie Trailer Queen | The Supremely Cunty Court |
| Cancun Cruz | The Border Runway |
| Moscow Mitch | The Fili-Buster Lounge |
| Elmo Musk | Gerrymandered Gauntlet |
| Mike Dense | Pray Away the Slay |
| Greg Ablot | Mar-a-Lardo's Dinner Theatre |
| Don the Con (Boss) | The Gilded Throne Room |
| (No fighter — Versus only) | Pride Float of War |

In arcade mode, the 7 politicians are fought in random order on their home stages. Don the Con is always the final fight.

## Stages

### 1. The Supremely Cunty Court
Drag brunch on the steps of the Supreme Court. Mimosa glasses clink in the background. The justices' portraits have been replaced with glamour shots. A rotating bench of backup dancers serves as stage hazards.
- **Hazard:** A gavel slams down every 20 seconds, creating a floor shockwave (5 dmg, launches both fighters upward).

### 2. The Fili-Buster Lounge
A velvet-draped nightclub built inside the Senate chamber. The filibuster podium is now a DJ booth. Senate desks have bottle service. C-SPAN cameras replaced with ring lights.
- **Hazard:** The DJ drops the beat every 30 seconds — bass shockwave knocks both fighters airborne (no damage, repositions).

### 3. The Border Runway
A fashion runway built on top of the border wall. Spotlights sweep the desert. Razor wire replaced with sequin streamers. ICE vehicles spray-painted rainbow. Tumbleweeds in wigs.
- **Hazard:** Spotlight follows a random fighter — standing in it for 3+ seconds applies a "dazzle" debuff for 4 seconds (attack animations play but hitboxes are disabled 30% of the time — the attack deals 0 damage on those hits. Does not consume special meter on whiffed specials).

### 4. Pray Away the Slay
A megachurch converted into a ballroom competition. Stained glass windows depict iconic drag moments. The baptismal font is a glitter pool. Pews filled with cheering fans holding scorecards.
- **Hazard:** Holy water sprinklers activate every 25 seconds for 5 seconds — fighters in the spray are slowed 30%.

### 5. Book Ban Bonfire
A burning library where the banned books fight back. Floating books serve as platforms. Pages rain from the sky with quotes from banned authors. Neon sign: "THEY FEARED WHAT WE READ."
- **Hazard:** Banned books fly across stage every 10 seconds as projectiles (3 dmg). Getting hit grants +10% damage for 8 seconds (knowledge is power).

### 6. Mar-a-Lardo's Dinner Theatre
A tacky gold-plated ballroom with a drag dinner show. Classified documents scattered as napkins. Secret Service agents recording on phones. Everything gilded and tasteless.
- **Hazard:** Classified document folders slide across the floor every 15 seconds — stepping on one causes a 1-second stun (slip and fall).

### 7. Gerrymandered Gauntlet
The stage keeps changing shape. Platforms appear and vanish, boundaries redraw mid-fight. Background shows a map being redrawn in real-time. Districts twist into absurd shapes.
- **Hazard:** Stage layout redraws every 20 seconds from a pool of 5 predefined layouts. 1-second warning flash before redraw. Fighters are pushed to the nearest safe ground if a wall would spawn on their position. Each layout has different platform placements and wall positions but maintains the same overall stage width.

### 8. Pride Float of War
A massive pride parade float rolling through Washington D.C. Capitol dome in background. Speakers, rainbow flags, confetti cannons. The crowd cheers louder based on combo hits.
- **Hazard:** The float turns corners every 15 seconds — momentum pushes both fighters toward one side (100px force over 2 seconds).

### ★ The Gilded Throne Room (Boss Stage)
Don the Con's exclusive arena. Gold-plated Oval Office with a drag runway down the center. 40-foot portrait behind the desk. Fox News on every screen but the headlines are about how badly he's losing.
- **Hazard:** At 25% HP, Don slams the big red button — "FAKE NEWS" banners drop and obscure 20% of the screen (random edges) for the rest of the fight. Visual obstruction only, no damage.

---

## Arcade Mode Flow

1. Player selects a drag queen
2. Fights 7 politicians in random order on their mapped stages
3. After defeating all 7, cutscene: "One more stands in your way..."
4. Final boss fight: Don the Con on The Gilded Throne Room
5. Victory screen with queen-specific ending and catchphrase
6. Don the Con unlocked for versus mode

## Balance Table

| Fighter | HP | Speed | Punch | Kick | Special | Role |
|---------|-----|-------|-------|------|---------|------|
| Valencia Thunderclap | 95 | 340 | 6 | 8 | 35 | Counter/Evasion |
| Mama Molotov | 130 | 260 | 11 | 13 | 30 | Rage Tank |
| Anita Riot | 90 | 350 | 8 | 9 | 28 | Rushdown/Disrupt |
| Dixie Normous | 100 | 290 | 7 | 8 | 22 | Debuffer |
| Siren St. James | 105 | 240 | 12 | 14 | 32 | Precision Glass Cannon |
| Rex Hazard | 115 | 270 | 10 | 11 | 30 | Grappler |
| Thornia Rose | 100 | 280 | 7 | 9 | 25 | Zone Control |
| Aurora Borealis | 95 | 300 | 6 | 7 | 28 | Ranged/Sustain |
| Ron DeSanctimonious | 110 | 280 | 9 | 10 | 0 | Move Denial (utility special) |
| Marjorie Trailer Queen | 95 | 330 | 9 | 11 | 30 | Chaotic Rushdown |
| Cancun Cruz | 100 | 310 | 7 | 8 | 26 | Zoner/Coward |
| Moscow Mitch | 140 | 200 | 8 | 9 | 20 | Stall Tank |
| Elmo Musk | 100 | 290 | 7 | 8 | 28 | Gadget/Resource |
| Mike Dense | 105 | 270 | 9 | 10 | 24 | Holy Warrior |
| Greg Ablot | 110 | 260 | 9 | 11 | 26 | Trap Specialist |
| **Don the Con** | **160** | **230** | **12** | **14** | **35** | **Final Boss** |

## Technical Notes

- Each fighter extends the existing `Fighter` base class
- Passives require a new `passive_proc()` method on the base class, called each frame
- Character-specific resources (Ego Meter, Riot Mode, Capital) extend the special meter system as secondary resource bars
- Input disruption effects need a new input remapping layer between `Input.get_action()` and the fighter's `handle_input()`
- Stage hazards need a `StageHazard` base class with timer/trigger systems and a `hazard_effect()` method
- Don the Con's phase transition requires a boss-specific state machine with Phase 1 → Phase 2 (40% HP) → FAKE NEWS (25% HP)
- Stat degradation (Dixie's reads) requires a runtime stat modifier dictionary on the Fighter base class
- Knockback resistance derived from HP: `knockback_modifier = 100 / fighter_HP`
- Mike Dense's "Mother" NPC needs a simple companion AI: follow Mike, auto-block on 10-second cooldown
- Elmo Musk's Capital resource needs a secondary UI element and spend-menu (mapped to taunt + direction inputs)
