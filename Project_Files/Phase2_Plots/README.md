# Phase 2 figure check

Checked on November 14, 2026 using MATLAB R2024b Update 5 and Signal Processing Toolbox 24.2, against Tasks 4-9 on page 4 of `MTE252_Project01.pdf`.

## Inputs and figures

`MTE252_Phase2.m` reads four existing MP3s directly from `Project_Files/audio/`. No WAV conversion or temporary input files are required. Stereo channels are summed as required by Task 3.2 and as implemented in Phase 1. Processing uses 32 kHz to support the upper 8 kHz band edge.

The ten PNGs here were regenerated from those MP3s. The script selects the highest-energy 80 ms input window for each Task 6 plot and a half-second window centered on it for Task 9. Times are relative to the start of each recording. Tiled layouts and `exportgraphics` preserve titles, axis labels, tick labels, and legends.

| Recording | Task 6 window (s) | Task 9 window (s) |
| --- | --- | --- |
| speech_house_memories | 16.207-16.287 | 15.997-16.497 |
| speech_world_cup_interview | 24.718-24.798 | 24.508-25.008 |
| speech_lean_management | 8.108-8.188 | 7.898-8.398 |
| music_treasure_island | 11.961-12.041 | 11.751-12.251 |

## Validation

- Ran the script from MATLAB's temporary working directory to verify that input and output paths depend on the script location.
- Checked the actual plotted curves in all ten figures for finite, nonzero data, and visually inspected every PNG for meaningful signals and readable labels.
- Verified that all eight bandpass filters and the envelope lowpass have poles inside the unit circle, with -3.010300 dB gain at the specified band edges and 400 Hz cutoff.
- Verified stereo summation, finite/nonzero outputs in all eight channels of the final recording, and the intended plot-window lengths.
- Checked that a missing MP3 raises an error before the script creates output figures.
- `matlab_run.log` records the direct MP3 run and assertion results. Temporary test helpers and files from the earlier WAV-based check were removed after validation.

Low-channel envelope ripple and small negative undershoots are effects of the specified causal 400 Hz lowpass, rather than instability. Rectification of the 100-172.9 Hz channel introduces ripple below 400 Hz, which this filter preserves. The high-channel envelope is substantially smoother than its rectified input. No built-in envelope extraction function is used.
