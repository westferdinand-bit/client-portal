# Assembly — the finished 45s cut

Assembled with **higgsedit** in the Higgsfield sandbox (`sandbox_exec`), not by hand.
The whole edit is one script, `edit.jsx`, so re-running it reproduces the cut exactly.

**Output:** 45.000s · 1440x2560 · 24fps · h264 + aac · 48.5 MB · 1080 frames · 0 diagnostics
**Video:** https://d2ol7oe51mr4n9.cloudfront.net/user_3Ek2XNuZ0a6HCF3IekPxegumfxG/c7e72cca-5626-4a04-a617-b8e294b9f0ff.mp4
**Contact sheet:** https://d2ol7oe51mr4n9.cloudfront.net/user_3Ek2XNuZ0a6HCF3IekPxegumfxG/c826e7dc-9972-4a90-befd-900ef5f14964.jpg

## Picture spine

| Clip | At | Dur | Source in |
|---|---|---|---|
| 1 hook run | 0.0 | 5.0 | 0-5.0 |
| 2 crane $20M → $700M | 5.0 | 14.0 | 0-14.0 |
| 3 subway | 19.0 | 5.0 | 0-5.0 |
| 4 the crossing | 24.0 | 14.5 | 0-14.5 |
| 5 rooftop CTA | 38.5 | 6.5 | 0-6.5 |

## The VO split — cut on a real word boundary
faster-whisper transcribed the Bram take with word timestamps, so the crossing silence sits
on an actual boundary instead of a guess. "…toy and a tool." ends at **31.84s** in the source.

| | At | Source | Ends |
|---|---|---|---|
| Cold open air | 0.00 | — | 1.20 |
| VO part A (hook → "toy and a tool") | 1.20 | 0 → 31.84 | 33.04 |
| **The crossing silence** | 33.04 | — | 36.60 (**3.56s**) |
| VO part B ("AI video just crossed it. Follow…") | 36.60 | 32.32 → 36.32 | 40.60 |
| Rooftop tail | 40.60 | — | 45.00 |

The cut to the rooftop at 38.5 lands between "crossed it" and "Follow" — the picture changes
in the gap between two sentences, not across a word.

## Text overlays (composed, not generated)
`Still think AI is cooling off?` 0.4 · `$20M / A YEAR AGO` 8.5 · `$700M / TODAY` 11.4 ·
`30,000,000 / PEOPLE USE IT` 19.1 · `390 / OF THE FORTUNE 500` 24.0 ·
`LEVEL COMPLETE` + `Follow for more` 38.8

Anton for the numbers, Inter 700 for labels, both vendored into the project so the build
fails loudly rather than silently shipping in a fallback face. Every overlay sits above
y=2100 to clear platform UI. Each number is timed to the sentence that speaks it.

## Three engine gotchas, for next time
1. `p.cut()` hardcodes `lane: 0` — it **cannot** place audio ("audio and visual clips never
   share a track"). Build the picture, then `higgsedit do <dir> place --trackIndex 2` for the
   audio. Lane 1 is taken by composed graphics.
2. `animate` must be an **array** of animations. The SKILL example shows a bare object; the
   runtime refuses it.
3. The sandbox is discarded seconds after a call ends — a background job's lease dies with
   the job. Chain download → build → render → upload into **one** script or the files vanish
   between calls. This cost one full render.

## Not verified
Proof frames were checked programmatically — all six distinct, correct dimensions, none blank
(RMSE 0.30-0.35 between them, mean luma 37-59). They were **not** visually inspected: this
environment has no way to display a remote image. Watch the cut.
