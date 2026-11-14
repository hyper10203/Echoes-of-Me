# Echoes of Me — Asset Specification

## Technical baseline

- **Godot viewport:** 960 x 540 logical pixels, stretched with `canvas_items`.
- **Production scale:** draw gameplay/UI raster assets at **2x** their runtime size, then display at 50%. This gives clean output in the 1280 x 720 window and leaves headroom for high-DPI displays.
- **Visual format:** PNG with alpha for sprites, props, tiles, VFX, and UI. SVG is acceptable for the logo and simple UI icons. Avoid JPG for sharp edges or transparency.
- **World scale:** one room is roughly **2,880 x 540 game units** (three camera-widths). Backgrounds should be split into three 960 x 540 runtime chunks per layer.
- **Pixel treatment:** no required pixel-art grid. If working pixel-style, use nearest-neighbor filtering and keep the 2x scale consistent.

## Shared character and world kit

| Asset | Suggested path | Source size | Runtime size / setup |
|---|---|---:|---|
| Adult Mara sprite sheet | `art/characters/mara/mara_sheet.png` | 384 x 768 | 6 columns x 8 rows, 64 x 96 source cells, displayed as 32 x 48. Bottom-center feet pivot. Keep the current collision box at 22 x 38. Rows: idle 6, run 8, jump 2, fall 2, land 2, interact 4, shift 6, respawn 4. |
| Child echo sheet | `art/characters/mara/mara_echo_sheet.png` | 384 x 768 | Same cell layout and pivot as Mara, so it can swap into past/echo moments without changing gameplay. |
| Mara portraits | `art/portraits/mara_adult.png`, `mara_child_echo.png` | 512 x 512 each | Alpha PNG, head-and-shoulders inside a 440 x 440 safe crop. Used in journal, title, and ending. |
| Structural tile sheet | `art/tiles/bellwether_tileset.png` | 1024 x 1024 | 16 x 16 grid of 64 x 64 source tiles, displayed at 32 x 32. Include stone floor, cracked wall, beams, trim, broken edge, wet edge, shadow, inner/outer corners, and 4 wear variants. Leave 2 source px transparent gutter between cells. |
| Platform overlays | `art/tiles/platform_overlays.png` | 512 x 256 | 8 x 8 grid of 64 x 32 source cells, displayed at 32 x 16. Visual-only top/side caps; collision remains code-driven. |
| Exit door sheet | `art/props/exit_door_sheet.png` | 192 x 192 | 2 x 1 grid, 96 x 192 source cells, displayed at 48 x 96. Locked and open states. Bottom-center pivot. |
| Time-anchor sheet | `art/props/time_anchor_sheet.png` | 384 x 96 | 4 x 1 grid, 96 x 96 source cells, displayed at 48 x 48. Dormant, ready, past, activated. Center pivot. Current interaction point is `(260, 440)`. |
| Memory props | `art/props/memories/{bell,clapper,moon,weight,wheel,prism,gear,page,lamp}.png` | 128 x 128 each | Display at 64 x 64. Center pivot. Keep important artwork inside 104 x 104 source px. Current interaction point is `(515, 438)`. |

## Level background packages

Each level uses **three parallax layers** across **three camera-width chunks**. Make nine files per level:

`art/backgrounds/l##_name/{far,mid,near}_{01,02,03}.png`

Each source file is **1920 x 1080** and displays at **960 x 540**. `far` is opaque; `mid` and `near` have transparency. Keep major navigation silhouettes out of the foreground's lower 120 runtime px so platforms remain readable.

| Level | Background-specific assets | Route assets | Puzzle visual asset |
|---|---|---|---|
| 01 Rain Porch | rain sheets, porch pillars, distant bell | `route_rope_segment.png`, 128 x 64 source / 64 x 32 runtime | `puzzle_bell_dial.png`, 512 x 256 source |
| 02 Bell Corridor | hanging bells, sound-wave wall decals | `route_catwalk.png`, 256 x 64 / 128 x 32; `bounce_clapper.png`, 128 x 96 / 64 x 48 | `puzzle_echo_rings.png`, 512 x 256 |
| 03 West Nursery | moon mobile, mirror, chalk outlines | `route_moon_stone.png`, 128 x 64 / 64 x 32 | `puzzle_moon_hooks.png`, 512 x 256 |
| 04 Laundry Lift | pulley room, ledger, pipes | `route_lift.png`, 320 x 96 / 160 x 48; cable tile 64 x 256 / 32 x 128 | `puzzle_weights.png`, 512 x 256 |
| 05 Cistern Rim | waterline, sluice walls, recovered tag | `route_sluice_stone.png`, 128 x 64 / 64 x 32; water strip 256 x 64 / 128 x 32 | `puzzle_valves.png`, 512 x 256 |
| 06 Glasshouse | cracked glass, leaves, sun shafts | `route_light_ledge.png`, 256 x 48 / 128 x 24 | `puzzle_mirrors.png`, 512 x 256 |
| 07 Clock Room | clock faces, exposed mechanism | `route_gear_platform.png`, 224 x 80 / 112 x 40 | `puzzle_clock.png`, 512 x 256 |
| 08 Flood Archive | shelves, pages, rescue report | `route_archive_shelf.png`, 256 x 96 / 128 x 48 | `puzzle_report_cards.png`, 512 x 256 |
| 09 Undercroft | roots, lamp, damp masonry | `route_pulse_bridge.png`, 256 x 64 / 128 x 32 | `puzzle_signal_lamps.png`, 512 x 256 |
| 10 Bell Tower | tower beams, giant bell, echo rings | `route_bell_ring.png`, 160 x 64 / 80 x 32 | `puzzle_resonance.png`, 512 x 256 |

Moving assets must use a **center pivot**. Route art has to fit inside the collision shapes defined by the game: normal platforms are 16 runtime px high, the lift is 150 x 18 runtime px, clock gears are 104 x 16 runtime px, and bell rings are 78 x 16 runtime px.

## UI, story, and effects kit

| Asset | Suggested path | Source size | Runtime setup |
|---|---|---:|---|
| Game logo | `art/ui/logo_echoes_of_me.png` | 1400 x 500 | Display about 700 x 250. Alpha PNG or SVG. Keep all title details readable at half scale. |
| Panel 9-slice | `art/ui/panel_9slice.png` | 96 x 96 | Source border 24 px, displayed border 12 px. Supports title, HUD, puzzle panel, pause, and case file. |
| UI icon atlas | `art/ui/icon_atlas.png` | 512 x 512 | 8 x 8 grid of 64 px cells, displayed at 32 px. Include movement, jump, interact, shift, journal, pause, restart, locked/open door, and tension markers. |
| Keycap set | `art/ui/keycaps/{a,d,e,q,h,j,r,space,esc}.png` | 96 x 72 each | Display at 48 x 36. Optional replacement for text prompts. |
| Clue cards | `art/story/clues/clue_01.png` through `clue_10.png` | 800 x 450 each | Display at 400 x 225 in the case file. One readable visual metaphor per recovered clue. |
| VFX sheet | `art/vfx/echo_fx_sheet.png` | 512 x 256 | 8 x 4 grid of 64 px cells, displayed at 32 px. Time shift, anchor pulse, repair spark, bounce dust, respawn mist, and echo rings. |
| Particle textures | `art/vfx/{mote,rain_drop,glow_dot}.png` | 32 x 32 each | Display 4–16 px. Alpha PNG with generous transparent padding for soft particles. |
| Fonts | `art/fonts/` | TTF/OTF | One readable OFL body face and one distinctive heading face. Include a `LICENSE.txt` next to each font. |

## Audio package

| Group | Suggested path | Format / target |
|---|---|---|
| Music | `audio/music/{title,present,past,ending}.ogg` | Stereo OGG, 48 kHz, loop-safe, roughly -16 LUFS integrated. |
| Movement | `audio/sfx/{jump,land,bounce,fall,respawn}.wav` | Mono WAV, 48 kHz, 24-bit, 0.1–0.8 sec. |
| Time and puzzle feedback | `audio/sfx/{anchor_awaken,shift_in,shift_out,repair,bell,gear,water,pulse}.wav` | WAV, 48 kHz, 24-bit. Loops may use OGG with clean loop points. |
| Room ambience | `audio/ambience/l01_rain.ogg` through `l10_tower_wind.ogg` | Stereo OGG, 48 kHz, 30–90 sec seamless loops. |
| Optional voices | `audio/voice/mara_{child,adult}_01..10.ogg` | Mono OGG, 48 kHz; provide matching subtitle text. |

## Delivery rules for final assets

- Log every created or acquired asset in `docs/ASSET_REGISTER.md`: source/creator, license, modification, credit, and final project path.
- Keep collision shapes separate from visual art. Replacing a sprite must not alter a jump or route width.
- Use alpha-safe PNG/SVG for anything that overlays the game. Use no copyrighted game art, logos, or unlicensed fonts.
- Test each moving-platform sprite at its real pivot and every background chunk at the camera seams.
