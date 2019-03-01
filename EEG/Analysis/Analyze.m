function Analyze(hObject, handles)
    subjects = get(handles.subjectsList, 'String');
    subjects = subjects(get(handles.subjectsList, 'Value'));
    sessions = get(handles.sessionsList, 'String');
    sessions = sessions(get(handles.sessionsList, 'Value'));
    runs = get(handles.runsList, 'String');
    runs = runs(get(handles.runsList, 'Value'));
   
    savingProperties.folder             = [get(handles.analysisFolder, 'String')  '/'];
    savingProperties.shouldSave         = get(handles.saveAnalysis, 'Value');
    savingProperties.shouldRecompute    = ~get(handles.recomputeAnalysis, 'Value');
    savingProperties.fullSave           = get(handles.fullSaveRadioButton, 'Value');
    dataFolder              = [get(handles.subjectFolderTextBox,'String') '/'];
    shouldComputeGASubject  = get(handles.perSubject, 'Value');
    shouldComputeGASession  = get(handles.perSession, 'Value');
    shouldDisplayRun        = get(handles.perRun, 'Value');
    
    bar = progressBar(handles.progressbar);
    handles.bar = bar;
    guidata(hObject, handles);
    processedRuns = cell(length(subjects), length(sessions));
    errorMessage = {};
    
    nbProcessedRuns = 0;
    subjectSessions = {};
    for subjectIndex = 1: length(subjects) 
        pathToSubject = fullfile(dataFolder,subjects{subjectIndex});
        for sessionIndex = 1:length(sessions)
            pathToSession = fullfile(pathToSubject,sessions{sessionIndex});
            sessionRuns = {};
            for runIndex = 1:length(runs)
                handles = guidata(hObject);
                if handles.shouldStop
                    break;
                end
                pathToRun = fullfile(pathToSession,runs{runIndex});
                if exist(pathToRun)
                    
                    message = {['Subject: ' subjects{subjectIndex}], ...
                        ['Session: ' sessions{sessionIndex}], ...
                        ['Run: ' runs{runIndex}], ''};
                    progress.current = nbProcessedRuns/length(runs);
                    progress.step = 1/length(runs);
                    nbProcessedRuns = nbProcessedRuns + 1;
%                     try
                        precomputedFile = runs{runIndex};
                        precomputedFile(end-2:end) = 'mat';
                        savingProperties.precomputedFile = precomputedFile;
                        eegrun = TryProcessingRun(pathToRun, progress, message, handles, savingProperties);
                        
                        if eegrun.loaded
                            eegrun.cleanRun();
                            sessionRuns{end+1} = eegrun;
                            if shouldDisplayRun
                                visualize(handles, message, progress, eegrun);
                            end
                        end
%                     catch e
%                         errorMessage{end + 1} = ['Error: ' e.message];
%                         set(handles.errorLog, 'String', errorMessage);
%                     end
                end
            end
            processedRuns{subjectIndex, sessionIndex} = sessionRuns;
            if shouldComputeGASession
                emptyGa = zeros(size(sessionRuns{1}.mvt,1),0,size(sessionRuns{1}.mvt,3));
                emptySpectGa = zeros(size(sessionRuns{1}.spectMvt,1),0,size(sessionRuns{1}.spectMvt,3),size(sessionRuns{1}.spectMvt,4));
                sessionData = struct('gaMvt', emptyGa, 'gaRest', emptyGa, 'gaSpectMvt', emptySpectGa, 'gaSpectRest', emptySpectGa);
                for indexRun = 1:length(sessionRuns)
                    sessionData = extendsData(sessionData, sessionRuns{indexRun});
                end
                eegrun = putDataInRun(sessionRuns{indexRun}.copy(), sessionData);
                visualize(handles, message, progress, eegrun);
            end
        end
        %% Compute grand average for offline and online extension and flexion sessions
        if shouldComputeGASubject
            analyzeGrandAverageForSubject(processedRuns, subjectIndex);
        end
    end
    if shouldComputeGASubject
        
    end
    if handles.shouldStop
        errorMessage{end + 1} = ['Process cancelled by user.'];
        set(handles.errorLog, 'String', errorMessage);
        handles.shouldStop = false;
        guidata(hObject, handles);
    end
end

function visualize(handles, message, progress, eegRun)
    frequenciesToPlot   = [8 12; 12 16; 16 20; 20 28]; %Hz
    %% Visualization
    message{4} = 'Visualizing';
    set(handles.log, 'String', message);
    handles.bar.update(progress.current + progress.step * 1);

    if get(handles.topoplot, 'Value') == 1
        EEGDisplayer.topoplotPSDOfTwoClasses(nanmean(eegRun.mvt,2), ...
            nanmean(eegRun.rest,2), ...
            eegRun.spectProperties.frequencies, ...
            frequenciesToPlot, ...
            eegRun.channelsData64, ...
            eegRun.labels)
    end
    if get(handles.spectrogram, 'Value') == 1
        baseline = eegRun.getSpecificEventTypeTimes(eegRun.uniqueEvents.Baseline, eegRun.uniqueEvents.Baseline,1);
        trialStart = eegRun.getSpecificEventTypeTimes(eegRun.uniqueEvents.Baseline, eegRun.uniqueEvents.Start,1);
        events = horzcat(baseline, trialStart);
        eventLabels = {'Baseline', 'Start'};
        SpectrogramDisplayer().plotSpectrogramForTwoClasses(...
            squeeze(nanmean(eegRun.spectMvt,2)),...
            squeeze(nanmean(eegRun.spectRest,2)), ...
            eegRun.spectProperties, ...
            {eegRun.channelsData.labels},...
            events,...
            eventLabels,...
            eegRun.labels);
    end
    if get(handles.discriminancyMap, 'Value') == 1
        EEGDisplayer().displayDiscriminancyMap(eegRun);
    end
end
