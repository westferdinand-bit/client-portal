# v2 — three revisions

**Video:** https://d2ol7oe51mr4n9.cloudfront.net/user_3Ek2XNuZ0a6HCF3IekPxegumfxG/13df1640-5d67-466d-9957-f8ccf8512a07.mp4
45.000s · 1440x2560 · 24fps · h264 + aac · 1080 frames · 0 diagnostics

---

## 1. Higgsfield title card — 5.20s to 8.40s
Sits over the narration line "Higgsfield just raised four hundred million dollars"
(source 4.14-6.40 = timeline 5.34-7.60), so it is on screen slightly before the name is
said and holds past it.

- `HIGGSFIELD` — Anton 186, white, letterspaced
- A yellow rule that wipes out from the left under it (scaleX 0 to 1 over 0.55s)
- `SERIES B — AUG 2026` — Inter 700, 46, grey

**This is a type treatment, not their logo.** I did not reproduce or invent Higgsfield's
actual mark — a fabricated version of a real company's logo is worse than no logo. If you
want the real one, send me the asset (SVG or transparent PNG) and I will swap the wordmark
for it in one build.

## 2. Audio — the clips were burying the narration
The generated clips carry their own ambience, and it was loudest exactly where you heard it.

Measured on v1:

| Window | v1 mean | note |
|---|---|---|
| 25-30s | **-11.0 dB** | loudest in the video, under "390 of the Fortune 500" |
| 20-25s | -15.6 dB | the coin cascade |
| clip 4 alone | -15.1 dB, **max 0.0 dB** | clipping |

**What did not work:** the `duck` verb. Four spans applied cleanly (`ops` returned for each),
and it worked on clip 1 — the cold open dropped -20.1 to -29.2 dB — but the clip 4 region did
not move at all. Rather than reverse-engineer its span semantics, the ambience is now
attenuated at source with ffmpeg before import, which is deterministic:

| Clip | Attenuation | Result |
|---|---|---|
| 1 hook | -12 dB | -30.9 dB |
| 2 crane | -12 dB | -31.2 dB |
| 3 subway (coins) | -16 dB | -36.2 dB |
| 4 crossing | **-20 dB** | -35.1 dB (was -15.1) |
| 5 rooftop | -14 dB | -33.7 dB |

Verified on the render:

| | v1 | v2 |
|---|---|---|
| Cold open (ambience only) | -20.1 dB | **-32.1 dB** |
| Crossing silence (ambience only) | -33.9 dB | **-54.0 dB** |
| 20-25s (narration) | -15.6 | -21.7 |
| 25-30s (narration) | -11.0 | -21.1 |

Narration now sits ~11 dB above the bed everywhere, and nothing clips. The crossing silence
at -54 dB is now genuinely silent rather than merely quiet.

## 3. Captions — 13 cards, cut to the VO
Timed from the same faster-whisper word timestamps as the VO split, so each card appears on
the words it transcribes. Long sentences are split into two cards rather than wrapping.

Inter 700 / 52px, white, on a #080A10 card at 74% opacity, rounded 20px, y 2000-2122 —
above the platform UI zone. 0.12s fades so they snap rather than drift.

Text is corrected against the source, not taken raw from Whisper: Whisper heard
"$390 of the Fortune 500"; the caption reads "390 of the Fortune 500 are on it,".

The stat overlays moved up (30M to y=1500, 390 to y=1450, CTA block to 1450/1660) to clear
the caption band.

## Engine note for next time
Adding 13 caption clips pushed the graphics onto lane 2, so the audio `place --trackIndex 2`
that worked in v1 failed with "track 2 holds visual clips". The lane index is now read from
the project after build rather than hardcoded:

```
NEXT=$(higgsedit read proj | python3 -c "import json,sys;print(len(json.load(sys.stdin)['tracks']))")
```

## Still not visually verified
Levels and durations are measured. The picture is not — this environment cannot display a
remote image. Watch the cut for caption legibility over the busy Times Square footage.
