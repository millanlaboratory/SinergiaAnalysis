function analyzeGrandAverageForSubject(processedRuns, subjectIndex)
    sessionOfflineFlexData  = [];
    sessionOnlineFlexData   = [];
    sessionOfflineExtData   = [];
    sessionOnlineExtData    = [];
    for sessionIndex = 1:size(processedRuns, 2)
        sessionRuns = processedRuns{subjectIndex, sessionIndex};
        for indexRun = 1:length(processedRuns{subjectIndex, sessionIndex})
            if sessionRuns{indexRun}.isFlexion() && sessionRuns{indexRun}.runType == EEGRunType.Calibration
                if isempty(sessionOfflineFlexData)
                    eegRunOfflineFlex = sessionRuns{indexRun};
                    emptyGa = zeros(size(eegRunOfflineFlex.mvt,1),0,size(eegRunOfflineFlex.mvt,3));
                    emptySpectGa = zeros(size(eegRunOfflineFlex.spectMvt,1),0,size(eegRunOfflineFlex.spectMvt,3),size(eegRunOfflineFlex.spectMvt,4));
                    sessionOfflineFlexData = struct('gaMvt', emptyGa, 'gaRest', emptyGa, 'gaSpectMvt', emptySpectGa, 'gaSpectRest', emptySpectGa);
                end
                sessionOfflineFlexData = extendsDataByRun(sessionOfflineFlexData, sessionRuns{indexRun});
            elseif sessionRuns{indexRun}.isFlexion() && sessionRuns{indexRun}.runType == EEGRunType.Online
                if isempty(sessionOnlineFlexData)
                    eegRunOnlineFlex = sessionRuns{indexRun};
                    emptyGa = zeros(size(eegRunOnlineFlex.mvt,1),0,size(eegRunOnlineFlex.mvt,3));
                    emptySpectGa = zeros(size(eegRunOnlineFlex.spectMvt,1),0,size(eegRunOnlineFlex.spectMvt,3),size(eegRunOnlineFlex.spectMvt,4));
                    sessionOnlineFlexData = struct('gaMvt', emptyGa, 'gaRest', emptyGa, 'gaSpectMvt', emptySpectGa, 'gaSpectRest', emptySpectGa);
                end
                sessionOnlineFlexData = extendsDataByRun(sessionOnlineFlexData, sessionRuns{indexRun});
            elseif sessionRuns{indexRun}.isExtension() && sessionRuns{indexRun}.runType == EEGRunType.Calibration
                if isempty(sessionOfflineExtData)
                    eegRunOfflineExt = sessionRuns{indexRun};
                    emptyGa = zeros(size(eegRunOfflineExt.mvt,1),0,size(eegRunOfflineExt.mvt,3));
                    emptySpectGa = zeros(size(eegRunOfflineExt.spectMvt,1),0,size(eegRunOfflineExt.spectMvt,3),size(eegRunOfflineExt.spectMvt,4));
                    sessionOfflineExtData = struct('gaMvt', emptyGa, 'gaRest', emptyGa, 'gaSpectMvt', emptySpectGa, 'gaSpectRest', emptySpectGa);
                end
                sessionOfflineExtData = extendsDataByRun(sessionOfflineExtData, sessionRuns{indexRun});
            elseif sessionRuns{indexRun}.isExtension() && sessionRuns{indexRun}.runType == EEGRunType.Online
                if isempty(sessionOnlineExtData)
                    eegRunOnlineExt = sessionRuns{indexRun};
                    emptyGa = zeros(size(eegRunOnlineExt.mvt,1),0,size(eegRunOnlineExt.mvt,3));
                    emptySpectGa = zeros(size(eegRunOnlineExt.spectMvt,1),0,size(eegRunOnlineExt.spectMvt,3),size(eegRunOnlineExt.spectMvt,4));
                    sessionOnlineExtData = struct('gaMvt', emptyGa, 'gaRest', emptyGa, 'gaSpectMvt', emptySpectGa, 'gaSpectRest', emptySpectGa);
                end
                sessionOnlineExtData = extendsDataByRun(sessionOnlineExtData, sessionRuns{indexRun});

            end
        end
    end
    eegRunOfflineFlex = putDataInRun(eegRunOfflineFlex, sessionOfflineFlexData);
    eegRunOnlineFlex = putDataInRun(eegRunOnlineFlex, sessionOnlineFlexData);
    eegRunOfflineExt = putDataInRun(eegRunOfflineExt, sessionOfflineExtData);
    eegRunOnlineExt = putDataInRun(eegRunOnlineExt, sessionOnlineExtData);
    visualize(handles, message, progress, eegRunOfflineFlex);
    visualize(handles, message, progress, eegRunOnlineFlex);
    visualize(handles, message, progress, eegRunOfflineExt);
    visualize(handles, message, progress, eegRunOnlineExt);
end