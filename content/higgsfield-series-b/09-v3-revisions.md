# v3 — pacing, caption style, karaoke timing

**Video:** https://d2ol7oe51mr4n9.cloudfront.net/user_3Ek2XNuZ0a6HCF3IekPxegumfxG/ecdef70e-a37a-429f-9210-26cdef124fff.mp4
**41.000s** (was 45.000) · 1440x2560 · 24fps · h264 + aac · 984 frames · 0 diagnostics

---

## 1. The dead air after "toy and a tool" — cut from 3.56s to 0.80s

That pause was mine, deliberately: a beat for the thesis line to land. Heard back at
speed it reads as a stall, not a beat. Your call wins — it is now **0.80s**, enough to
separate the two thoughts without the video appearing to hang.

Everything downstream moved up, and the whole cut is 4 seconds shorter:

| | v2 | v3 |
|---|---|---|
| VO part A | 1.20 → 33.04 | unchanged |
| Gap | **3.56s** | **0.80s** |
| VO part B | 36.60 → 40.60 | 33.84 → 37.84 |
| Clip 4 (crossing) | 24.0 → 38.5 | 24.0 → 35.7 |
| Clip 5 (rooftop) | 38.5 → 45.0 | 35.7 → 41.0 |
| Total | 45.000s | **41.000s** |

The cut to the rooftop still lands in the gap between "crossed it" and "Follow", not
across a word. CTA hold is 3.3s after the last word.

## 2. Captions now sit on the picture — no black box

The card is gone. Legibility now comes from the type itself, which is what keeps
captions feeling part of the image instead of pasted over it:

- Inter 700 at **78px**, white, centre-aligned
- **11px black stroke** — carries it over the neon Times Square footage
- Soft drop shadow (y 6, blur 24) to lift it off busy backgrounds
- Moved up to y=1880, off the very bottom edge

The same treatment went onto every other element — the stats, the HIGGSFIELD card, the
hook and the CTA all gained shadows, so nothing relies on a solid backing plate any
more. Stats moved up (30M to 1330, 390 to 1280, CTA to 1280/1490) to clear the captions.

## 3. Captions now track the voice — 35 chunks, word-timed

Was: 13 sentence cards, each sitting for 2-3 seconds. That is a subtitle, not a caption.

Now: faster-whisper is re-run with `word_timestamps=True`, and the words are grouped
into **35 chunks** of at most 3 words / 1.15s, breaking on sentence punctuation. Each
chunk's clip runs from its first word's start to its last word's end, mapped through the
same offsets as the VO split (part A +1.20, part B +1.52). The text changes as the words
are spoken, because the timings *are* the spoken timings.

First four, straight from the render:

```
[1.200, 0.600, "If you think"]
[1.800, 0.800, "the AI boom"]
[2.600, 1.040, "is cooling off,"]
[3.960, 0.540, "look at this"]
```

Each chunk snaps in over 0.09s with a 0.92 → 1 scale pop, and out in 0.06s — fast
enough to feel spoken rather than dissolving.

Whisper's `$390` mis-hear is corrected in the generator, so the caption reads `390`.

## Reproducibility
`edit.jsx` is now generated from a template plus a whisper-derived caption table, so
re-running the pipeline regenerates the exact same 35 chunks from the audio. The chunker
lives in the build script, not hand-typed timings.

## Still not visually verified
Duration, frame count and codecs are measured. The picture is not — this environment
cannot display a remote image. The stroke weight over Times Square is the thing most
worth your eye.
