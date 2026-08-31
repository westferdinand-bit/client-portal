# VO Script — Higgsfield Series B, 45s

Pip narrates. One voice, no second speaker. Read it like a New York kid telling you
something he just found out and can't quite believe — quick, a little clipped, confident by
the end. Not announcer-smooth, not hype-bro.

Numbers are written as words below because TTS reads digits inconsistently. Do not
"correct" them back to numerals.

---

## Timed read

| # | In | Line | Notes |
|---|---|---|---|
| 1 | 0:00 | "If you think the AI boom is cooling off, look at this number." | Flat, matter-of-fact. Do not sell it. |
| 2 | 0:04 | "Higgsfield just raised four hundred million dollars." | Beat after "dollars." |
| 3 | 0:08 | "A year ago it made twenty million." | Drop pitch. Small. |
| 4 | 0:11 | "Today it's at seven hundred million a year." | Land hard on "seven hundred million." |
| 5 | 0:15 | "That's thirty-five times, in twelve months." | Quick, thrown away. |
| 6 | 0:18 | "Thirty million people use it." | Pick the pace back up. |
| 7 | 0:21 | "And here's the part that actually matters —" | Lean in. Trail off into the cut. |
| 8 | 0:24 | "Three hundred ninety of the Fortune Five Hundred are on it," | Steady, unhurried. |
| 9 | 0:29 | "and businesses now make up most of the revenue." | This is the thesis. Slow down. |
| 10 | 0:33 | "That's the line between a toy and a tool." | Full stop after. Let it sit. |
| 11 | 0:38 | "AI video just crossed it." | Quiet. Certain. |
| 12 | 0:41 | "Follow — I'll keep you ahead of this stuff." | Cocky half-smile in the voice. |

**95 words.** At ~2.2 words/sec (spoken numbers run slow) that's **≈43 seconds**, leaving
~2s of headroom.

## The two silences
Both are load-bearing — do not let the music fill them.

- **0:34–0:38**, after "toy and a tool." The Times Square bed has already cut out at the
  crossing. Four seconds of near-silence over the Financial District.
- **0:17–0:18**, the tiny gap before "Thirty million people use it," so the $700M reveal
  has somewhere to land.

## RENDERED

### Take 1 — WRONG VOICE, discard
Job `1379ff85-cd87-4762-89f1-6deef9e26da6` · 44.78s. Generated on `seed_audio`, which is **not
in Bram's supported engine list** (`elevenlabs`, `minimax`, `seed_speech`, `qwen_audio`). The
call did not fail — seed_audio silently substituted its own internal speaker (`S_vfbPNHP82`)
and returned no `voice` object at all. That is why it sounded nothing like the preview.

**Rule for every future VO on this project:** check the voice's `supported_models` before
generating, and use `model: "text2speech_v2"` with a `variant` from that list. `seed_audio`
only honours a voice id when that voice actually supports it; otherwise it substitutes without
warning.

### Take 2 — Bram via ElevenLabs ✅
Job `922b8951-799e-4d96-955b-38cdfc06aea9` · MP3 · **36.4 seconds**. Response confirms
`voice.name: "Bram"`, `model: "elevenlabs"`.

### Take 3 — Bram via MiniMax ✅
Job `fb72344c-d3cc-43d1-b4c9-5083f0112a40` · MP3 32kHz · **37.76 seconds**. Same voice, second
engine, for comparison.

## The trim is no longer needed — reverting that recommendation
The line-5 cut was only ever a fix for take 1's bloated 44.78s. At 36.4s the full script sits
**8.6 seconds under** the 45s slot, which is exactly the headroom the beat sheet wants:

| | |
|---|---|
| Video runtime | 45.0s |
| Bram / ElevenLabs read | 36.4s |
| Available silence | **8.6s** |

Spend it as: ~4s for the crossing silence after "toy and a tool", ~1.5s of cold-open air
before the first line, ~1s before "Thirty million people use it", and ~2s of tail after the
CTA. Keep line 5. It has room now.

## If it runs long
Cut line 5 first ("That's thirty-five times, in twelve months") — the 2A→2B scale jump
already says it, and it's the only line that repeats a visual. Cut line 6 second.

## Delivery notes for the generator
- Male-ish young adult read, American, light New York edge. Not a deep announcer voice.
- Conversational pace with real pauses, not even metering.
- No smile in the voice until line 12.
- Generate as one continuous take, not twelve clips — the pauses come out natural and you
  avoid twelve separate room tones. Cut to the timing grid afterward in the edit.
