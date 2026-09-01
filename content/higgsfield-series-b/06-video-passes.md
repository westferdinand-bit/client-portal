# Video Passes — 5 clips

**Model: `minimax_h3` at 2K, 9:16.** Chosen after preflighting four options:

| Model | Res | Start+end frames | Cost |
|---|---|---|---|
| **minimax_h3** | **2K** | **yes** | **2 cr/sec** |
| minimax_h3_max | 768p | yes | 2.5 cr/sec |
| kling3_0_turbo | 1080p | start only | 2 cr/sec |
| flux_3_video | 1080p | yes | 9 cr/sec |

minimax_h3 wins outright — highest resolution, keyframe support, joint-cheapest. Using one
model for all five clips also avoids mixing resolutions in the edit, which would show.

## Clips

| # | Beat | Dur | Frames | Job | Cost |
|---|---|---|---|---|---|
| 1 | Hook | 5s | start: Frame 1 | `8c1396d6-aaee-49a1-84d0-c1689ff63709` | 10 |
| 2 | The jump | 15s | start: 2A → end: 2B | `e74f8c82-f30f-46e2-a4f3-23059ef08b85` | 30 |
| 3 | Scale | 6s | start: Frame 3 | `5125dcf8-08da-4194-aab8-6db32aa60d16` | 12 |
| 4 | The crossing | 15s | start: 4A → end: 4B | `7b6b40b5-90bb-4771-b6c0-266275acc53d` | 30 |
| 5 | CTA | 7s | start: Frame 5 | `567c3d05-c28d-4f67-a3be-0ca5d9c87e28` | 14 |

**96 credits. 48s of footage** cut down to the 45s slot.

## Preset interception — worth knowing for next time
Clips 3, 4 and 5 came back `submission_failed` with *"Preset 'IN THE DARK' was recommended
instead of submitting a job."* The server offers a style preset in place of the job rather than
running it. The fix is `declined_preset_id: "24bae836-2c4a-48e0-89b6-49fcc0b21612"` on the
retry, which suppresses that one recommendation. Declined here because the art direction is
already locked and a dark moody preset would break it.

## RENDERED — all five complete
All 2K, 1440x2560, 9:16, no watermark. 96 credits.

| # | Beat | Dur | Output |
|---|---|---|---|
| 1 | Hook | 5s | `hf_20260831_235223_8c1396d6-...mp4` |
| 2 | The jump (crane) | 15s | `hf_20260831_235222_e74f8c82-...mp4` |
| 3 | Scale (subway) | 6s | `hf_20260831_235245_5125dcf8-...mp4` |
| 4 | The crossing | 15s | `hf_20260831_235245_7b6b40b5-...mp4` |
| 5 | CTA (rooftop) | 7s | `hf_20260831_235245_567c3d05-...mp4` |

Clips 2 and 4 both confirm start_image AND end_image were accepted, so the keyframe pairs
drove the camera as intended rather than the model improvising the move.

## What to check on the clips
1. **Clip 2 must be one continuous crane.** If it cuts, whip-pans or resets, the scale reveal
   dies. This is the highest-risk clip in the set.
2. **Clip 4 must come to a complete stop.** The whole point is that motion ends at the line.
   If the camera drifts through the ending, the silence after has nothing to sit against.
3. **Character drift.** Watch the beanie, the amber orb and the red laces across all five —
   video models wander more than image models do.
4. **Stray text.** Every prompt bans it, but check the departure board in clip 3 and any
   signage in clip 4.

## Then
Text overlays (`$20M`, `$700M`, `30,000,000`, `390`, `LEVEL COMPLETE`) in the edit, VO laid to
the timing grid in `04-vo-script.md`, silences per the 8.6s budget, SFX and city bed per the
beat sheet.
