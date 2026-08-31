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

## RENDERED — Bram, take 1
Job `1379ff85-cd87-4762-89f1-6deef9e26da6` · seed_audio · voice Bram (preset,
`549ff70a-3ee7-4f04-a4d9-89a24fab7709`) · WAV 24kHz · **44.78 seconds**.

That is a fit for the 45-second slot with **0.2s to spare** — technically passing, practically
too tight. There is no room to top-and-tail it, and the four-second silence specced at
0:34-0:38 almost certainly is not in this take, because the read is near-continuous.

**Recommended: re-render without line 5.** Dropping "That's thirty-five times, in twelve
months" takes roughly 3 seconds off, landing near 41-42s, which gives the crossing silence
somewhere to live and leaves handles at both ends. It is also the only line that repeats
information the 2A-to-2B scale jump already delivers visually.

## If it runs long
Cut line 5 first ("That's thirty-five times, in twelve months") — the 2A→2B scale jump
already says it, and it's the only line that repeats a visual. Cut line 6 second.

## Delivery notes for the generator
- Male-ish young adult read, American, light New York edge. Not a deep announcer voice.
- Conversational pace with real pauses, not even metering.
- No smile in the voice until line 12.
- Generate as one continuous take, not twelve clips — the pauses come out natural and you
  avoid twelve separate room tones. Cut to the timing grid afterward in the edit.
