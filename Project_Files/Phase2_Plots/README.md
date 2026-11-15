# Phase 2 figure check

Checked on November 14, 2026 using MATLAB R2024b Update 5 and Signal Processing Toolbox 24.2, against Tasks 4-9 on page 4 of `MTE252_Project01.pdf`.

The filter calculations pass numerical checks, but the script does not process the repository's inputs as-is, and the generated figures need presentation changes before inclusion in the report.

## Runs and inputs

- Ran the existing `MTE252_Phase2.m` from `Project_Files`. It saved the two filter-response figures, warned that all four WAV inputs were missing, and skipped the Task 6/9 figures despite printing a completion message.
- For a complete check, decoded the four matching MP3 recordings in `audio/` into temporary 32-bit WAV files at their original sampling rates. Ran an unchanged copy of the script beside those WAVs in a temporary directory. The ten PNGs here are from that run; temporary WAVs were not added to the repository.
- The source and executed copy had matching SHA-256 hashes: `24DA2AE95859F229224774743645FF67E2F73D5E321EA0561CFFC9E26B74D051`.
- Input durations were 27.517 s (house memories), 29.428 s (World Cup), 28.141 s (lean management), and 25.588 s (Treasure Island); their sampling rates were 48, 44.1, 48, and 44.1 kHz respectively. The script resampled them to 32 kHz.
- `matlab_run.log` records both runs and the subsequent numerical checks. The MATLAB source was not edited.

## Verified behavior

- All eight bandpass filters and the envelope lowpass have poles inside the unit circle.
- Every bandpass has -3.010300 dB gain at its specified edges, covering 100-8000 Hz. The lowpass has approximately 0 dB DC gain, -3.010300 dB gain at 400 Hz, and -56.350296 dB gain at 2000 Hz.
- All eight channels produced finite, nonzero bandpass and envelope signals over each complete recording.
- All ten PNGs were created at 875 x 656 pixels and visually inspected. The filter bank shows the intended eight bands. The high-channel envelope suppresses rapid rectification ripple; the low-channel output retains ripple because rectification of the 100-172.9 Hz channel produces components below the required 400 Hz cutoff.

## Issues found

1. **Input paths:** the script expects four bare `.wav` filenames beside it. The repository contains `.mp3` inputs under `audio/`; Phase 1 writes `<name>_processed.wav`. Align input paths and names before expecting a complete run directly from this checkout.
2. **Unrepresentative plot window:** every Task 6/9 plot shows only the first 80 ms. Both World Cup figures are entirely flat because that window is silent, although later channel outputs are nonzero. House memories mainly shows a tiny startup transient; lean management and Treasure Island show very low-level opening content. Select an active segment, preferably with a longer envelope overview, for useful report figures.
3. **Export layout:** the lowpass figure clips the magnitude axis label and portions of tick labels; several Task 6/9 figures clip the rightmost time tick or bottom axis text. Check figure size, layout, and export margins before using the PNGs in the report.
4. **Amplitude interpretation:** stereo channels are averaged here, whereas Task 3.2 and `phase_one.m` add them. Stereo amplitudes are consequently half those of the Phase 1 sum. The causal lowpass also produces small negative undershoots; the minimum among the lowest/highest-channel envelopes was approximately -0.001532. These do not indicate instability, but the filtered output is not guaranteed to be strictly nonnegative.
