% MTE 252 Project - Phase 2: Filter Design (Tasks 4-9)
% Emad Rahman, Taha Malik, Saahib Lall, Abdulaziz Abbas
% Requires Signal Processing Toolbox.

%% Setup and Audio Files
clear; clc; close all;

scriptFolder = fileparts(mfilename('fullpath'));
audioFolder = fullfile(scriptFolder, 'audio');
files = {
    'speech_house_memories.mp3'
    'speech_world_cup_interview.mp3'
    'speech_lean_management.mp3'
    'music_treasure_island.mp3'
};

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
figurePosition = [100, 100, 1000, 750];

if targetFs <= 2*maxFreq
    error('targetFs must be greater than 2*maxFreq for bandpass design.');
end
for fileIndex = 1:numel(files)
    filename = fullfile(audioFolder, files{fileIndex});
    if ~isfile(filename)
        error('Missing MP3 file: %s.', filename);
    end
end

%% Task 4: Design Bandpass Filter Bank
bandEdges = logspace(log10(minFreq), log10(maxFreq), N+1);
bpB = cell(1, N);
bpA = cell(1, N);

for k = 1:N
    Wn = bandEdges(k:k+1) / (targetFs/2);
    [bpB{k}, bpA{k}] = butter(bpPrototypeOrder, Wn, 'bandpass');
end

% Design the Task 8 lowpass once for all channels and recordings.
[lpB, lpA] = butter(lpOrder, envelopeCutoff/(targetFs/2), 'low');

%% Task 5: Apply Bandpass Filters
for fileIndex = 1:numel(files)
    filename = fullfile(audioFolder, files{fileIndex});

    [x, originalFs] = audioread(filename);
    x = sum(x, 2);  % Sum stereo channels, as in Phase 1.

    if originalFs <= 2*maxFreq
        warning(['%s was recorded at %d Hz: its source Nyquist frequency ' ...
            'is only %.0f Hz. Upsampling cannot restore missing ' ...
            'high-frequency content.'], filename, originalFs, originalFs/2);
    end
    if originalFs ~= targetFs
        x = resample(x, targetFs, originalFs);
    end

    numSamples = numel(x);
    t = (0:numSamples-1).' / targetFs;
    bandpassed = zeros(numSamples, N);
    for k = 1:N
        bandpassed(:, k) = filter(bpB{k}, bpA{k}, x);
    end

    %% Task 6: Plot Lowest and Highest Channels
    % Select active audio instead of leading silence.
    shown = min(numSamples, max(1, round(plotDuration*targetFs)));
    windowEnergy = movsum(x.^2, [0, shown-1]);
    [~, startSample] = max(windowEnergy(1:numSamples-shown+1));
    plotSamples = startSample:startSample+shown-1;
    [~, baseName] = fileparts(filename);
    figure('Color', 'w', 'Position', figurePosition);
    for channelIndex = 1:numel(channels)
        k = channels(channelIndex);
        subplot(2, 1, channelIndex);
        plot(t(plotSamples), bandpassed(plotSamples, k)); grid on;
        xlabel('Time (s)'); ylabel('Amplitude');
        title(sprintf('Channel %d (%.1f - %.1f Hz)', k, bandEdges(k), bandEdges(k+1)));
    end
    sgtitle(sprintf('Task 6: bandpass outputs | %s', strrep(baseName, '_', ' ')));

    %% Task 7: Full-Wave Rectification
    rectified = abs(bandpassed);

    %% Task 8: Envelope Extraction
    envelopes = zeros(numSamples, N);
    for k = 1:N
        envelopes(:, k) = filter(lpB, lpA, rectified(:, k));
    end

    %% Task 9: Plot Extracted Envelopes
    % Center a longer view on the same active segment, within the recording.
    envelopeShown = min(numSamples, max(1, round(envelopeDuration*targetFs)));
    envelopeStart = startSample - round((envelopeShown-shown)/2);
    envelopeStart = max(1, min(envelopeStart, numSamples-envelopeShown+1));
    envelopeSamples = envelopeStart:envelopeStart+envelopeShown-1;

    figure('Color', 'w', 'Position', figurePosition);
    for channelIndex = 1:numel(channels)
        k = channels(channelIndex);
        subplot(2, 1, channelIndex);
        plot(t(envelopeSamples), rectified(envelopeSamples, k), 'Color', [0.70, 0.70, 0.70]); hold on;
        plot(t(envelopeSamples), envelopes(envelopeSamples, k), 'b', 'LineWidth', 1.5); hold off;
        grid on; xlabel('Time (s)'); ylabel('Amplitude');
        title(sprintf('Channel %d envelope (%.1f - %.1f Hz)', k, bandEdges(k), bandEdges(k+1)));
        legend('Rectified', sprintf('%g Hz lowpass output', envelopeCutoff), 'Location', 'best');
    end
    sgtitle(sprintf('Task 9: extracted envelopes | %s', strrep(baseName, '_', ' ')));

    fprintf('Processed %s\n', files{fileIndex});
end

%% Additional: Filter Frequency Responses
figure('Color', 'w', 'Position', figurePosition);
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

[Hlp, flp] = freqz(lpB, lpA, 8192, targetFs);
figure('Color', 'w', 'Position', figurePosition);
plot(flp, 20*log10(max(abs(Hlp), 1e-10)), 'LineWidth', 1.3);
grid on; xlim([0, 2000]); ylim([-80, 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title(sprintf('Phase 2: %g Hz Butterworth envelope lowpass filter', envelopeCutoff));

fprintf('\nCompleted Phase 2 processing. Figures are open for viewing and manual saving.\n');
