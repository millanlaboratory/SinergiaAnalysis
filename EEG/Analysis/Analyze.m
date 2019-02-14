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
    dataFolder          = [get(handles.subjectFolderTextBox,'String') '/'];
    
    bar = progressBar(handles.progressbar);
    handles.bar = bar;
    guidata(hObject, handles);
    discardedRuns = [];
    errorMessage = {};
    for subjectIndex = 1: length(subjects) 
        pathToSubject = fullfile(dataFolder,subjects{subjectIndex});
        for sessionIndex = 1:length(sessions)
            pathToSession = fullfile(pathToSubject,sessions{sessionIndex});
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
                    progress.current = (runIndex-1)/length(runs);
                    progress.step = runIndex/length(runs);
%                     try
                        precomputedFile = runs{runIndex};
                        precomputedFile(end-2:end) = 'mat';
                        savingProperties.precomputedFile = precomputedFile;
                        [eegrun, psdAnalysis] = TryProcessingRun(pathToRun, progress, message, handles, savingProperties);

%                     catch e
%                         errorMessage{end + 1} = ['Error: ' e.message];
%                         set(handles.errorLog, 'String', errorMessage);
%                         discardedRuns(end+1) = runIndex;
%                     end
                end
            end
        end
    end
    if handles.shouldStop
        errorMessage{end + 1} = ['Process cancelled by user.'];
        set(handles.errorLog, 'String', errorMessage);
        handles.shouldStop = false;
        guidata(hObject, handles);
    end
end