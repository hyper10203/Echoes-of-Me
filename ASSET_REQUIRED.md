# Echoes of Me — Assets Required

This is the handoff list for replacing the current original, code-drawn placeholder visuals. Keep all gameplay collision and routes code-driven; art must fit the measurements below rather than changing level geometry.

## Visual direction

- **Mood:** rain-dark, analog-memory mystery; deep navy and wet stone, with one readable accent colour per level.
- **Style:** painted 2D with clean silhouettes and restrained glowing ink. Avoid photorealism, pixel-art mixed with painterly work, heavy bloom, or unreadable dark-on-dark props.
- **Scale:** the game runs at **960 x 540**. Supply PNGs at **2x** listed runtime dimensions and display them at 50%.
- **Format:** alpha PNG for game art and UI; OGG for music/ambience; WAV for short effects. No copyrighted characters, logos, or unlicensed fonts.

## Must-have production pack

| Asset | Source dimensions | Runtime use | Required states |
|---|---:|---|---|
| Mara sprite sheet | 384 x 768 | 32 x 48 character | 6 columns × 8 rows; idle, run, jump, fall, land, interact, shift, respawn; bottom-centre feet pivot |
| Child echo sheet | 384 x 768 | 32 x 48 ghost echo | Match Mara's grid and pivot |
| Structural tiles | 1024 x 1024 | 32 x 32 tiles | 16 × 16 cells; floors, walls, wet edges, cracks, beams, corners, shadows, 4 wear variants |
| Platform caps | 512 x 256 | 32 x 16 overlays | 8 × 8 cells; normal, wet, glass, gear and archive shelf caps |
| Time anchor | 384 x 96 | 48 x 48 interactable | 4 frames: dormant, available, past, activated; centre pivot |
| Exit door | 192 x 192 | 48 x 96 door | 2 frames: sealed/open; bottom-centre pivot |
| Memory props | 9 × 128 x 128 | 64 x 64 interactables | bell, clapper, moons, weights, valve, prism, gear, report, signal lamp |
| Puzzle boards | 10 × 1536 x 448 | 748 x 224 display | Bell dial, echo rings, moon hooks, weights, valves, mirrors, clock, cards, lamps, resonance; no baked-in text |
| UI panel 9-slice | 96 x 96 | all UI panels | 24px source border; transparent centre; blue-black glass and thin metal edge |
| UI icon atlas | 512 x 512 | 32 x 32 icons | 8 × 8 cells; move, jump, interact, shift, journal, pause, restart, locked/open, difficulty |
| VFX sheet | 512 x 256 | 32 x 32 effects | 8 × 4 cells; anchor pulse, time shift, repair spark, bounce dust, respawn mist, echo ring |

## Background package per level

Create three parallax layers for each of the 10 levels. Every layer is split into three **1920 x 1080 source** chunks, each shown as **960 x 540** at runtime:

`art/backgrounds/l##_name/{far,mid,near}_{01,02,03}.png`

- **Far:** opaque painted atmosphere.
- **Mid:** transparent architectural silhouettes.
- **Near:** transparent foreground details only. Keep the lower 120 runtime pixels clear so routes remain readable.

Unique route art: rope, catwalk/clapper, moon stones, laundry lift, sluice stones, light ledges, gear platforms, archive shelves, pulse bridge, and bell rings. Moving pieces require a **centre pivot** and must fit their existing collision size.

## UI and story assets

| Asset | Source dimensions | Notes |
|---|---:|---|
| Logo | 1400 x 500 | Alpha PNG or SVG; no tagline baked in |
| Mara portraits | 512 x 512 each | Adult and child echo; face/shoulders inside a 440px safe area |
| Evidence cards | 10 × 800 x 450 | One visual clue per recovered memory; displayed at 400 x 225 |
| Keycaps | 96 x 72 each | A, D, E, Q, H, J, R, Space, Esc; displayed 48 x 36 |
| Fonts | TTF/OTF | One OFL body family and one OFL display family; include licence text |

## Audio

- Music: `title`, `present`, `past`, `ending` as stereo 48 kHz OGG, loop-safe, around -16 LUFS.
- Ambience: 10 room loops as stereo 48 kHz OGG, 30–90 seconds.
- SFX: jump, land, bounce, fall, respawn, anchor, shift in/out, repair, bell, gear, water, pulse as mono 48 kHz 24-bit WAV.
- Optional voice fragments: mono 48 kHz OGG with matching subtitles.

## Delivery checks

1. Log every final asset in `docs/ASSET_REGISTER.md` with creator/source, licence, credit, path and verification state.
2. Test every 9-slice, tile seam, moving-platform pivot, and three-chunk background seam in the live game.
3. Keep UI text as game text—do not bake puzzle instructions, controls, or story prose into images.

See `docs/ASSET_SPEC.md` for the exhaustive per-level filename map and collision fit notes.
