% MTE 252 Project - Phase 2: Filter Design (Tasks 4-9)
% Emad Rahman, Taha Malik, Saahib Lall, Abdulaziz Abbas
% Requires Signal Processing Toolbox.

clear; clc; close all;

scriptFolder = fileparts(mfilename('fullpath'));
audioFolder = fullfile(scriptFolder, 'audio');
files = {'speech_house_memories.mp3', 'speech_world_cup_interview.mp3', 'speech_lean_management.mp3', 'music_treasure_island.mp3'};

targetFs = 32000;
N = 8;
minFreq = 100;
maxFreq = 8000;
envelopeCutoff = 400;
bpPrototypeOrder = 2;       % Bandpass order is twice the prototype order.
lpOrder = 4;
plotDuration = 0.08;
envelopeDuration = 0.5;
channels = [1, N];
channelNames = {'Lowest', 'Highest'};
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

bandEdges = logspace(log10(minFreq), log10(maxFreq), N+1);
bpB = cell(1, N);
bpA = cell(1, N);

fprintf('Phase 2: %d channels; processing Fs = %d Hz\n', N, targetFs);
for k = 1:N
    Wn = bandEdges(k:k+1) / (targetFs/2);
    [bpB{k}, bpA{k}] = butter(bpPrototypeOrder, Wn, 'bandpass');
    fprintf('Channel %d: %8.2f Hz to %8.2f Hz\n', k, bandEdges(k), bandEdges(k+1));
end

[lpB, lpA] = butter(lpOrder, envelopeCutoff/(targetFs/2), 'low');

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

for fileIndex = 1:numel(files)
    filename = fullfile(audioFolder, files{fileIndex});

    [x, originalFs] = audioread(filename);
    x = sum(x, 2);

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

    for k = 1:N
        bandpassed(:, k) = filter(bpB{k}, bpA{k}, x);
        rectified(:, k) = abs(bandpassed(:, k));
        envelopes(:, k) = filter(lpB, lpA, rectified(:, k));
    end

    % Select active audio instead of leading silence.
    shown = min(numSamples, max(1, round(plotDuration*targetFs)));
    windowEnergy = movsum(x.^2, [0, shown-1]);
    [~, startSample] = max(windowEnergy(1:numSamples-shown+1));
    plotSamples = startSample:startSample+shown-1;
    envelopeShown = min(numSamples, max(1, round(envelopeDuration*targetFs)));
    envelopeStart = max(1, min(startSample-round((envelopeShown-shown)/2), numSamples-envelopeShown+1));
    envelopeSamples = envelopeStart:envelopeStart+envelopeShown-1;

    [~, baseName] = fileparts(filename);
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', figurePosition);
    layout = tiledlayout(fig, 2, 1, 'TileSpacing', 'loose', 'Padding', 'loose');
    for channelIndex = 1:numel(channels)
        k = channels(channelIndex);
        nexttile(layout);
        plot(t(plotSamples), bandpassed(plotSamples, k)); grid on;
        ylabel('Amplitude');
        title(sprintf('%s channel (%.1f - %.1f Hz)', channelNames{channelIndex}, bandEdges(k), bandEdges(k+1)));
    end
    xlabel(layout, 'Time (s)');
    title(layout, sprintf('Task 6: bandpass outputs | %s', strrep(baseName, '_', ' ')));
    drawnow;
    exportgraphics(fig, fullfile(outputDir, [baseName '_task6_bandpass.png']), 'Resolution', 150);
    close(fig);

    fig = figure('Visible', 'off', 'Color', 'w', 'Position', figurePosition);
    layout = tiledlayout(fig, 2, 1, 'TileSpacing', 'loose', 'Padding', 'loose');
    for channelIndex = 1:numel(channels)
        k = channels(channelIndex);
        nexttile(layout);
        plot(t(envelopeSamples), rectified(envelopeSamples, k), 'Color', [0.70, 0.70, 0.70]); hold on;
        plot(t(envelopeSamples), envelopes(envelopeSamples, k), 'b', 'LineWidth', 1.5); hold off;
        grid on; ylabel('Amplitude');
        title(sprintf('%s channel envelope (%.1f - %.1f Hz)', channelNames{channelIndex}, bandEdges(k), bandEdges(k+1)));
        legend('Rectified', '400 Hz lowpass output', 'Location', 'best');
    end
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
