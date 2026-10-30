% MTE 252 Project - Phase 1, Task 3
% Emad Rahman, Taha Malik, Saahib Lall, Abdulaziz Abbas

clear; clc; close all;  clear sound;

files = {'speech_house_memories.wav', ...
         'speech_world_cup_interview.wav', ...
         'speech_lean_management.wav', ...
         'music_treasure_island.wav', ...
         'music_canon_in_d_major.mp3', ...
         'speech_county_fair_interview.mp3', ...
         'speech_loud_male.mp3', ...
         'speech_loud_female.mp3', ...
         'speech_background_noise.mp3', ...
         'speech_many_voices_noise.mp3'};

% Apply the same processing routine to every sound file
for k = 1:numel(files)
    [y, Fs] = processSound(files{k});
end


%% Local function 
% (Local functions must be placed at the end of a script file.)

function [y, Fs] = processSound(filename)
    targetFs = 16000;  
    f       = 1000;   

    fprintf('\n===== %s =====\n', filename);

    %% 3.1 Read the file and find its sampling rate
    [y, Fs] = audioread(filename);
    fprintf('Original sampling rate: %d Hz, %d samples\n', Fs, size(y, 1));

    if Fs < targetFs
        warning('%s is sampled below 16 kHz - consider re-recording it.', filename);
    end

    %% 3.2 Check mono/stereo; convert stereo to a single channel
    numChannels = size(y, 2);
    if numChannels == 2
        disp('Stereo - converting to mono');
        y = y(:, 1) + y(:, 2); 
    elseif numChannels == 1
        disp('Mono');
    end    

    %% 3.3 Play the sound
    sound(y, Fs);
    pause(length(y) / Fs + 0.5);

    %% 3.4 Write the sound to a new file
    [~, name, ~] = fileparts(filename);
    outName = [name '_processed.wav'];
    audiowrite(outName, y, Fs);
    fprintf('Saved %s\n', outName);

    %% 3.5 Plot the waveform vs. sample number
    figure;
    n = 1:length(y);
    plot(n, y);
    xlabel('Sample number');
    ylabel('Amplitude');
    title(['Waveform of ' filename], 'Interpreter', 'none');
    grid on;

    %% 3.6 Downsample to 16 kHz if needed
    if Fs ~= targetFs
        y  = resample(y, targetFs, Fs);
        Fs = targetFs;            
        fprintf('Resampled to %d Hz, %d samples\n', Fs, length(y));
    end

    %% 3.7 Generate a 1 kHz cosine with the same length and duration
    N = length(y);
    t = (0:N-1) / Fs;   
    x = cos(2*pi*f*t);

    sound(x, Fs);
    pause(N / Fs + 0.5);

    T   = 1 / f;      
    idx = t <= 2*T;          
    figure;
    plot(t(idx), x(idx), '-o');
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['1 kHz cosine - two cycles (length matched to ' filename ')'], 'Interpreter', 'none');
    grid on;
end
