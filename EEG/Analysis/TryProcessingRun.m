function [eegRun] = TryProcessingRun(pathToRun, progress, message, handles, savingProperties)

    %% Init run properties
    windowSize          = 1; % s
    frequenciesToStudy  = 4:0.1:30; %Hz
    frequenciesToPlot   = [8 12; 12 16; 16 20; 20 28]; %Hz
    epochFrequency      = 16; % Hz
    events = struct(...
        'Start',781, ...
        'Baseline',786, ...
        'Flexion',782,...
        'Extension',784, ...
        'OldExtension',781, ...
        'Rest', 783);
    overlap         = windowSize - 1/epochFrequency; % s
    spatialFilter   = SpatialFilterFactory.createSpatialFilter('CAR', 16);
    psdProperties   = PSDProperties(windowSize, overlap, frequenciesToStudy, epochFrequency);
    
    
    message{4} = 'Loading data';
    set(handles.log, 'String', message);
    handles.bar.update(progress.current + progress.step * 0);
    if ~(savingProperties.shouldRecompute || ~exist([savingProperties.folder '/' savingProperties.precomputedFile]))
         %% Load pre-processed data
        eegRun = load([savingProperties.folder '/' savingProperties.precomputedFile]);
        eegRun = eegRun.obj;
    else
        %% Load and pre-process raw data
        try
            eegRun = EEGRunData();
            eegRun.load(pathToRun);
        catch e
            return
        end
        eegRun.loaded = true;
        eegRun.uniqueEvents = events;
        message{4} = 'Computing PSD';
        set(handles.log, 'String', message);
        handles.bar.update(progress.current + progress.step * 0.2);
        eegRun.computePSDForAllChannels(psdProperties, spatialFilter, handles.errorLog);
        
        %% Extract events
        message{4} = 'Computing grand average';
        set(handles.log, 'String', message);
        handles.bar.update(progress.current + progress.step * 0.6);

        eegRun.extractEvents(events);
        eegRun.extractNormalizePSDPerTrial();
        [eegRun.mvt, ~, ~] = eegRun.getAveragedPSDForMovementPerTrial(events);
        [eegRun.rest, ~, ~] = eegRun.getAveragedPSDForRestPerTrial(events);
        eegRun.spectProperties = struct('time', [], 'frequencies', []);
        [eegRun.spectMvt, eegRun.spectProperties.time, eegRun.spectProperties.frequencies] = ...
            eegRun.getSpectrogramForMovementPerTrial(events);
        [eegRun.spectRest, ~, ~] = eegRun.getSpectrogramForRestPerTrial(events);
    end

    %% Saving Data
    message{4} = 'Saving Data';
    set(handles.log, 'String', message);
    handles.bar.update(progress.current + progress.step * 0.8);
    if savingProperties.shouldSave && (~exist([savingProperties.folder '/' savingProperties.precomputedFile]) || savingProperties.shouldRecompute)
        if ~exist(savingProperties.folder)
            mkdir(savingProperties.folder);
        end
        if(~savingProperties.fullSave)
            eegRun.cleanRun()
        end
        eegRun.saveRun(savingProperties.folder, savingProperties.precomputedFile);
    end
end

