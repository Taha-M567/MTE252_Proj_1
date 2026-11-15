% MTE 252 Project - Phase 2: Filter Design (Tasks 4-9)
% Emad Rahman, Taha Malik, Saahib Lall, Abdulaziz Abbas
%
% Reads the four Phase 1 MP3 recordings from the adjacent audio folder.
% Requires MATLAB Signal Processing Toolbox (butter, resample, freqz).
%
% Design: 8 logarithmically spaced Butterworth bandpass channels (100-8000 Hz)
% followed by full-wave rectification and a 400 Hz Butterworth lowpass.
%
% NOTE: Phase 1 used 16000 Hz. To use an upper band edge of 8000 Hz,
% processing here uses 32000 Hz (Nyquist = 16000 Hz). Upsampling a file
% originally recorded at 16000 Hz CANNOT recover frequencies above 8000 Hz.
% Use original high-rate recordings if available.
%
% The cosine synthesis from Phase 1 Task 3.7 is intentionally omitted:
% it is needed again in Phase 3, NOT in Phase 2.

clear; clc; close all;

scriptFolder = fileparts(mfilename('fullpath'));
audioFolder = fullfile(scriptFolder, 'audio');
files = {'speech_house_memories.mp3', 'speech_world_cup_interview.mp3', 'speech_lean_management.mp3', 'music_treasure_island.mp3'};

% ---- Configurable parameters (also useful for Phase 3) ----
targetFs = 32000;             % Hz; must be strictly greater than 2*8000
N = 8;                        % number of frequency channels
minFreq = 100;                % Hz
maxFreq = 8000;               % Hz
envelopeCutoff = 400;         % Hz
bpPrototypeOrder = 2;        % Butterworth bandpass order = 2*2 = 4
lpOrder = 4;                 % Butterworth lowpass order
plotDuration = 0.08;         % seconds shown in Task 6, selected from active audio
envelopeDuration = 0.5;      % seconds shown in Task 9 around the same segment
figurePosition = [100, 100, 1000, 750];
outputDir = fullfile(scriptFolder, 'Phase2_Plots');

if targetFs <= 2*maxFreq
    error('targetFs must be greater than 2*maxFreq for bandpass design.');
end
for fileIndex = 1:numel(files)
    filename = fullfile(audioFolder, files{fileIndex});
    if ~isfile(filename)
        error('Missing MP3 file: %s.', filename);
    end
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Task 4: logarithmic band edges, with adjacent nonoverlapping -3dB edges.
bandEdges = logspace(log10(minFreq), log10(maxFreq), N+1);
bpB = cell(1, N);
bpA = cell(1, N);

fprintf('Phase 2: %d channels; processing Fs = %d Hz\n', N, targetFs);
for k = 1:N
    lowHz = bandEdges(k);
    highHz = bandEdges(k+1);
    Wn = [lowHz, highHz] / (targetFs/2);  % normalized to Nyquist
    [bpB{k}, bpA{k}] = butter(bpPrototypeOrder, Wn, 'bandpass');
    fprintf('Channel %d: %8.2f Hz to %8.2f Hz\n', k, lowHz, highHz);
end

% Task 8 filter design: 400 Hz lowpass, applied after rectification.
[lpB, lpA] = butter(lpOrder, envelopeCutoff/(targetFs/2), 'low');

% Evidence for the design report: show all bandpass frequency responses.
fig = figure('Visible', 'off', 'Color', 'w', 'Position', figurePosition);
tiledlayout(fig, 1, 1, 'Padding', 'loose');
nexttile;
hold on;
for k = 1:N
    [H, freqHz] = freqz(bpB{k}, bpA{k}, 8192, targetFs);
    plot(freqHz, 20*log10(max(abs(H), 1e-10)), 'LineWidth', 1);
end
hold off; grid on;
xlim([0, maxFreq]); ylim([-80, 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title(sprintf('Phase 2: %d-channel Butterworth bandpass filter bank', N));
legend(compose('Ch %d', 1:N), 'Location', 'best');
drawnow;
exportgraphics(fig, fullfile(outputDir, 'filter_bank_response.png'), 'Resolution', 150);
close(fig);

% Additional filter-design evidence: envelope lowpass frequency response.
[Hlp, flp] = freqz(lpB, lpA, 8192, targetFs);
fig = figure('Visible', 'off', 'Color', 'w', 'Position', figurePosition);
tiledlayout(fig, 1, 1, 'Padding', 'loose');
nexttile;
plot(flp, 20*log10(max(abs(Hlp), 1e-10)), 'LineWidth', 1.3);
grid on; xlim([0, 2000]); ylim([-80, 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Phase 2: 400 Hz Butterworth envelope lowpass filter');
drawnow;
exportgraphics(fig, fullfile(outputDir, 'envelope_lowpass_response.png'), 'Resolution', 150);
close(fig);

% Tasks 5-9: run the same processing pipeline for each audio file.
for fileIndex = 1:numel(files)
    filename = fullfile(audioFolder, files{fileIndex});

    [x, originalFs] = audioread(filename);     % Phase 1: Task 3.1
    if size(x, 2) > 1
        x = sum(x, 2);                        % Phase 1: Task 3.2
    end
    x = x(:);

    if originalFs <= 2*maxFreq
        warning(['%s was recorded at %d Hz: its source Nyquist frequency ' 'is only %.0f Hz. Upsampling cannot restore missing ' 'high-frequency content.'], filename, originalFs, originalFs/2);
    end
    if originalFs ~= targetFs
        x = resample(x, targetFs, originalFs);
    end

    numSamples = numel(x);
    t = (0:numSamples-1).' / targetFs;
    bandpassed = zeros(numSamples, N);
    rectified = zeros(numSamples, N);
    envelopes = zeros(numSamples, N);

    % Tasks 5, 7, 8: filter, rectify, then lowpass each channel.
    for k = 1:N
        bandpassed(:, k) = filter(bpB{k}, bpA{k}, x);
        rectified(:, k) = abs(bandpassed(:, k));
        envelopes(:, k) = filter(lpB, lpA, rectified(:, k));
    end

    % Avoid leading silence by selecting the highest-energy 80 ms window.
    shown = min(numSamples, max(1, round(plotDuration*targetFs)));
    windowEnergy = movsum(x.^2, [0, shown-1]);
    [~, startSample] = max(windowEnergy(1:numSamples-shown+1));
    plotSamples = startSample:startSample+shown-1;
    envelopeShown = min(numSamples, max(1, round(envelopeDuration*targetFs)));
    envelopeStart = max(1, min(startSample-round((envelopeShown-shown)/2), numSamples-envelopeShown+1));
    envelopeSamples = envelopeStart:envelopeStart+envelopeShown-1;

    % Task 6: plot lowest and highest bandpass outputs.
    [~, baseName] = fileparts(filename);
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', figurePosition);
    layout = tiledlayout(fig, 2, 1, 'TileSpacing', 'loose', 'Padding', 'loose');
    nexttile(layout);
    plot(t(plotSamples), bandpassed(plotSamples, 1)); grid on;
    ylabel('Amplitude');
    title(sprintf('Lowest channel (%.1f - %.1f Hz)', bandEdges(1), bandEdges(2)));
    nexttile(layout);
    plot(t(plotSamples), bandpassed(plotSamples, N)); grid on;
    ylabel('Amplitude');
    title(sprintf('Highest channel (%.1f - %.1f Hz)', bandEdges(N), bandEdges(N+1)));
    xlabel(layout, 'Time (s)');
    title(layout, sprintf('Task 6: bandpass outputs | %s', strrep(baseName, '_', ' ')));
    drawnow;
    exportgraphics(fig, fullfile(outputDir, [baseName '_task6_bandpass.png']), 'Resolution', 150);
    close(fig);

    % Task 9: plot low/high envelopes compared to rectified outputs.
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', figurePosition);
    layout = tiledlayout(fig, 2, 1, 'TileSpacing', 'loose', 'Padding', 'loose');
    nexttile(layout);
    plot(t(envelopeSamples), rectified(envelopeSamples, 1), 'Color', [0.70, 0.70, 0.70]); hold on;
    plot(t(envelopeSamples), envelopes(envelopeSamples, 1), 'b', 'LineWidth', 1.5); hold off;
    grid on; ylabel('Amplitude');
    title(sprintf('Lowest channel envelope (%.1f - %.1f Hz)', bandEdges(1), bandEdges(2)));
    legend('Rectified', '400 Hz lowpass output', 'Location', 'best');
    nexttile(layout);
    plot(t(envelopeSamples), rectified(envelopeSamples, N), 'Color', [0.70, 0.70, 0.70]); hold on;
    plot(t(envelopeSamples), envelopes(envelopeSamples, N), 'b', 'LineWidth', 1.5); hold off;
    grid on; ylabel('Amplitude');
    title(sprintf('Highest channel envelope (%.1f - %.1f Hz)', bandEdges(N), bandEdges(N+1)));
    legend('Rectified', '400 Hz lowpass output', 'Location', 'best');
    xlabel(layout, 'Time (s)');
    title(layout, sprintf('Task 9: extracted envelopes | %s', strrep(baseName, '_', ' ')));
    drawnow;
    exportgraphics(fig, fullfile(outputDir, [baseName '_task9_envelopes.png']), 'Resolution', 150);
    close(fig);

    fprintf('Processed %-35s (%d samples, %.2f sec); Task 6 %.3f-%.3fs; Task 9 %.3f-%.3fs\n', ...
        files{fileIndex}, numSamples, numSamples/targetFs, ...
        t(plotSamples(1)), t(plotSamples(end)), t(envelopeSamples(1)), t(envelopeSamples(end)));
end

fprintf('\nCompleted Phase 2 processing. Plots saved in: %s\n', outputDir);
