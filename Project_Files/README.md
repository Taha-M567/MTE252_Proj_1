# Phase 1 audio processing

Run `phase_one.m` in MATLAB with Signal Processing Toolbox (`resample`). The script finds its input folder relative to its own location, so inputs do not depend on MATLAB's current folder.

```text
Project_Files/
  phase_one.m
  README.md
  audio/       # All 10 input clips, in MP3 format
```

Audio names use lowercase `<type>_<topic>.mp3`, with underscores between words. The four original WAV inputs were encoded as MP3; the six newer MP3 inputs retain their original audio data.

| Clip in `audio/` | Content | Original source filename/title |
| --- | --- | --- |
| `speech_house_memories.mp3` | Narration about an old house and memories | `acoustiangel.wav` |
| `speech_world_cup_interview.mp3` | 2018 World Cup interview | `bogenseeber.mp3` |
| `speech_lean_management.mp3` | Speech about lean management | `neilraouf.wav` |
| `music_treasure_island.mp3` | Treasure Island with backing music | `richardfosterpersonal.mp3` |
| `music_canon_in_d_major.mp3` | Pachelbel: Canon in D Major | `Pachelbel - Canon In D Major` |
| `speech_county_fair_interview.mp3` | Child interviewed at a Pennsylvania county fair | `apparently-kid-interviewed-at-pennsylvania-county-fair` |
| `speech_loud_male.mp3` | Loud male speech | `loud male speach` |
| `speech_loud_female.mp3` | Loud female speech | `loud woman speach` |
| `speech_background_noise.mp3` | Speech with background noise | `speach with background noise` |
| `speech_many_voices_noise.mp3` | Speech with multiple background voices | `speach with many voices noise` |

The script reads each clip, reports its sampling rate, combines stereo channels into mono, plays the clip, and saves `<name>_processed.wav` in MATLAB's current folder. It plots the waveform, resamples to 16 kHz, then generates and plays a matching-duration 1 kHz cosine and plots two cycles. Playback pauses let each sound finish.

Generated WAV files preserve the existing processing task; they are outputs, not input recordings. They are written before resampling, at the original sampling rate. MP3 conversion is lossy; filenames identify the same recordings but the converted samples are not bit-identical to the original WAVs.
