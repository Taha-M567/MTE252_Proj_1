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

## Phase 2 filter design

Run `MTE252_Phase2.m` in MATLAB with Signal Processing Toolbox. It reads the first four MP3 recordings listed above directly from `audio/`, sums stereo channels as in Phase 1, and resamples to 32 kHz for the 100-8000 Hz filter bank. Input and output paths are relative to the script, so MATLAB's current folder does not affect them. A missing input stops execution with an error.

The script saves ten PNG figures in `Phase2_Plots/`: two filter responses and Task 6/9 plots for each recording. Task 6 shows the highest-energy 80 ms segment; Task 9 shows a half-second view centered on that segment, with time labels measured from the recording's start. See `Phase2_Plots/README.md` for the figure checks.
