# Echoes of Me

*A small, original, Foddian-inspired time puzzle platformer for the Haven theme “Bounce Back.”*

## Run

Open this folder in Godot 4.x and press **F6** on `scenes/main.tscn`, or press **F5** after opening the project. No downloaded assets or plugins are needed. All art is drawn from original Godot shapes and colors.

## Controls

- **A / D** or **Left / Right:** move
- **Space:** jump (hold for a slightly higher jump)
- **E:** activate the time anchor nearby, then interact with the memory object in the past
- **Q:** shift between past and present at the anchor
- **W / S** or **Up / Down:** rotate or adjust the selected control during memory puzzles
- **H:** reveal a puzzle hint or replay a signal puzzle
- **J:** open the evidence journal and reread recovered clues
- **Escape / P:** pause or resume
- **R:** restart this level at its checkpoint (timeline edits stay)
- **Enter / Space:** start, continue, or finish the ending screen

Fall into a gap and you return to the current level's safe entrance. A repaired memory reveals that room's unique route for the rest of the run. Puzzle complexity rises from one broad timing window to a final reverse-echo synthesis puzzle; physical routes alternate sharp tests with slightly safer traversal so failed jumps remain fair. There are exactly ten connected levels; each right-hand doorway leads to the next.

Each room is three camera-widths wide. The camera follows Mara, so later paths and exits are not exposed at the entrance. The game also includes code-drawn ambient motes, time-shift lighting, and a screen-space vignette while final art is still pending.

## Story and level outline

Adult Mara Vale returns to Bellwether House after finding a cassette in her childhood handwriting: “You promised you would come back for me.” She was the only child reported missing in the bell flood, then found alive downstream. She never returned to the house. Now a second voice follows her through ten rooms. At each blue-glass anchor, she repairs one remembered action. The route that appears is different every time, and each repaired memory leaves a clue. The clues reveal that the past and present are the same moment, heard twice: the bell's acoustic echo and Mara's buried memory. The voice calling her home is her own.

| # | Place and connection | Memory puzzle | Present traversal | Clue / next link |
|---|---|---|---|---|
| 1 · 1/7 | Rain porch, the house entrance | Strike one bell inside a broad golden timing arc | Low rope bridge | A childhood note asks the listener to answer the second ring; the handwriting is Mara's. Enter the bell corridor |
| 2 · 2/7 | Bell corridor, beyond the porch | Catch three returning sound pulses | Spring launch onto a high catwalk | The second ring copies Mara's breath exactly; follow it to the nursery |
| 3 · 3/7 | West nursery | Rotate three crescent hooks to match the mirror | Eight narrow moon stones | Two chalk girls share one pair of shoes; the second is in the mirror. Descend to the lift |
| 4 · 3/7 | Laundry lift | Balance light, middle, and heavy counterweights | A long moving lift ride | Its ledger names one passenger: Mara, age eight; the return box is blank. Reach the cistern |
| 5 · 4/7 | Cistern rim | Turn three valves to route water to the drain | Nine uneven sluice stones | A recovered tag reads FOUND ALIVE, 8:17. Continue to Mother's glasshouse |
| 6 · 4/7 | Glasshouse | Rotate three panes to guide broken sunlight | One-way light ledges | Mother's diary says the bell only repeats what enters it; every clock is stopped at 8:17 |
| 7 · 5/7 | Clock room | Restore the exact time, 08:17 | Four quick gear platforms | The bell's low note continued after its last strike: an echo. The flood archive holds the report |
| 8 · 5/7 | Flood archive | Reconstruct a shuffled four-card rescue timeline | Nine shelf steps | The official report confirms Mara was found alive downstream at 8:17. The original tape is below |
| 9 · 6/7 | Undercroft | Watch then repeat a six-light signal | Long bridge with a timed bright window | Child-Mara and adult-Mara share the same breath on the tape. The bell tower has one answer left |
| 10 · 7/7 | Bell tower, above the entrance | Read a seven-note echo, then answer it backwards | Eight narrow, fast bell rings | Reveal: there was no second girl. Past and present are one moment heard twice—Mara's memory and the bell's echo. She survived. The voice calling her home is her own. She stops rewinding and leaves with the memory intact. |

Every recovered clue appears immediately on screen and is saved in the **J evidence journal**, so the story can be reread in sequence without rushing through a room.

## Project map

- `scenes/main.tscn` — reusable single-room game entry scene
- `scripts/game.gd` — movement, timeline, ten level records, collision, interface, story, progression
- `scripts/puzzle_display.gd` — reusable visual layer for the ten memory puzzle types
- `scripts/vignette.gd` — screen-space vignette effect
- `project.godot` — Godot 4 project settings and window setup
- `docs/ASSET_SPEC.md` — complete production asset list, dimensions, formats, and paths
- `ASSET_REQUIRED.md` — concise asset handoff, exact dimensions, and acceptance checks
- `docs/ASSET_REGISTER.md` — provenance tracker for placeholder and final assets

## Known limitations

This is a code-drawn placeholder-art build: no final illustrations, music, sound effects, gamepad mapping, save file, or localization. Each room now has a distinct memory puzzle and traversal structure; all puzzle hints can be opened with **H** so a failed attempt only resets the local mechanism.
