classdef EEGSubjectData < handle
    properties
        EEGSessionsData
        subjectID
        dataFolder
        saveAnalysisFolder = '/home/cnbi/analysis/BCICourse/'
        recompute = true
        changed = false
        grandAverages
        grandAveragesSpectrogram
        grandAveragesSpectrogramClass
    end
    methods
        function obj = EEGSubjectData(subjectID, saveAnalysisFolder, recompute)
            obj.subjectID           = subjectID;
            obj.saveAnalysisFolder  = [saveAnalysisFolder '/' subjectID];
            obj.recompute           = recompute;
        end
        
        %% Load 
        function loadSubjectSessions(obj, dataFolder, sessionsName)
            disp('Load subject sessions data');
            obj.dataFolder = dataFolder;
            obj.EEGSessionsData = cell(length(sessionsName),1);
            
            for sessionIndex = 1:length(obj.EEGSessionsData)
                obj.loadSession(sessionsName{sessionIndex}, sessionIndex);
            end
        end
        
        function loadSession(obj, sessionName, sessionIndex)
            obj.EEGSessionsData{sessionIndex} = EEGSessionData(sessionName);
            couldLoadPreviousAnalysis = false;
            if ~obj.recompute
                couldLoadPreviousAnalysis = obj.tryLoadingPreviousAnalysis(sessionName, sessionIndex);
            end
            if ~couldLoadPreviousAnalysis
                obj.EEGSessionsData{sessionIndex}.loadSession([obj.dataFolder obj.subjectID]);
                obj.changed = true;
            end 
        end
        
        function couldLoadPreviousAnalysis = tryLoadingPreviousAnalysis(obj, sessionName, sessionIndex)
            couldLoadPreviousAnalysis = false;
            filename = [obj.saveAnalysisFolder '/' sessionName '.mat'];
            if exist(filename, 'file') == 2
                obj.EEGSessionsData{sessionIndex} = load(filename);
                obj.EEGSessionsData{sessionIndex} = obj.EEGSessionsData{sessionIndex}.obj;
                couldLoadPreviousAnalysis = true;
            end 
        end
        
        %% Save
        function saveAnalysis(obj)
            disp('Save subject sessions');
            for sessionIndex = 1:length(obj.EEGSessionsData)
                filename = [obj.saveAnalysisFolder '/' obj.EEGSessionsData{sessionIndex}.sessionID '.mat'];
                if ~(exist(obj.saveAnalysisFolder, 'dir') == 7)
                    mkdir(obj.saveAnalysisFolder);
                end
                obj.EEGSessionsData{sessionIndex}.save(filename);
            end
        end
        
        %% PSD
        function computePSDForAllSessions(obj, psdProperties, spatialFilter)
            if obj.shouldComputePSDForAllSessions()
                disp('Compute PSD for all sessions');
                for sessionIndex = 1:length(obj.EEGSessionsData)
                    disp(['Session ' num2str(sessionIndex)]);
                    obj.EEGSessionsData{sessionIndex}.computePSDForAllRuns(psdProperties, spatialFilter);
                end
                obj.changed = true;
            end
        end
        
        function answer = shouldComputePSDForAllSessions(obj)
            answer = obj.recompute;
            if ~answer
                for sessionIndex = 1:length(obj.EEGSessionsData)
                    if obj.EEGSessionsData{sessionIndex}.shouldComputePSDForAllRuns()
                        answer = true;
                    end
                end
            end
        end
        
        function computePSDForAllOfflineSessions(obj, psdProperties, spatialFilter)
            if obj.shouldComputePSDForAllOfflineSessions()
                disp('Compute PSD for all offline sessions');
                for sessionIndex = 1:length(obj.EEGSessionsData)
                    disp(['Session ' num2str(sessionIndex)]);
                    obj.EEGSessionsData{sessionIndex}.computePSDForAllOfflineRuns(psdProperties, spatialFilter);
                end
                obj.changed = true;
            end
        end
        
        function answer = shouldComputePSDForAllOfflineSessions(obj)
            answer = obj.recompute;
            if ~answer
                for sessionIndex = 1:length(obj.EEGSessionsData)
                    if obj.EEGSessionsData{sessionIndex}.shouldComputePSDForAllOfflineRuns()
                        answer = true;
                    end
                end
            end
        end
        %% Grand Average
        function computeGrandAverage(obj, usedEvents, usedEventsSpectrogram)
            if obj.shouldComputeGrandAverage()
                disp('Compute Grand Average');
                grandAverage = [];
                grandAverageSpectrogram = [];
                for sessionIndex = 1:length(obj.EEGSessionsData)
                    
                    disp(num2str(obj.EEGSessionsData{sessionIndex}.sessionID));
                    obj.EEGSessionsData{sessionIndex}.computeGrandAveragePerRun(usedEvents);
                    obj.EEGSessionsData{sessionIndex}.computeGrandAverageSpectrogramPerRun(usedEventsSpectrogram)
                    if sessionIndex == 1
                        grandAverage = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRun{1}), length(obj.EEGSessionsData), 2]);
                        grandAverageSpectrogram =  nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpoch{1}), length(obj.EEGSessionsData)]);
                        grandAverageSpectrogramPerClass = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpochPerClass{1}), length(obj.EEGSessionsData), 2]);
                    end
                    ga = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpoch{1}), obj.EEGSessionsData{sessionIndex}.nbOfCalibrationRuns]); 
                    gaclass = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRun{1,1}), obj.EEGSessionsData{sessionIndex}.nbOfCalibrationRuns, 2]);
                    gaSpectClass = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpochPerClass{1,1}), obj.EEGSessionsData{sessionIndex}.nbOfCalibrationRuns, 2]);                    
                    for runIndex = 1:size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpoch,1)
                        ga(:,:,:, runIndex) = obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpoch{runIndex};
                        gaclass(:,:, runIndex, 1) = obj.EEGSessionsData{sessionIndex}.grandAveragesPerRun{runIndex, 1};
                        gaclass(:,:, runIndex, 2) = obj.EEGSessionsData{sessionIndex}.grandAveragesPerRun{runIndex, 2};
                        gaSpectClass(:,:,:, runIndex, 1) = obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpochPerClass{runIndex, 1};
                        gaSpectClass(:,:,:, runIndex, 2) = obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpochPerClass{runIndex, 2};
                    end
                    grandAverage(:,:,sessionIndex,1) = nanmean(gaclass(:,:,:,1),3);
                    grandAverage(:,:,sessionIndex,2) = nanmean(gaclass(:,:,:,2),3);
                    grandAverageSpectrogram(:,:,:,sessionIndex) = nanmean(ga(:,:,:,:),4);
                    grandAverageSpectrogramPerClass(:,:,:,sessionIndex,1) = nanmean(gaSpectClass(:,:,:,:,1),4);
                    grandAverageSpectrogramPerClass(:,:,:,sessionIndex,2) = nanmean(gaSpectClass(:,:,:,:,2),4);
                    obj.changed = true;
                end
                obj.grandAverages = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRun{1,1}), 2]);
                obj.grandAveragesSpectrogram = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpoch{1}), 2]);
                obj.grandAveragesSpectrogramClass = nan([size(obj.EEGSessionsData{sessionIndex}.grandAveragesPerRunPerEpochPerClass{1,1}), 2]);
                obj.grandAverages(:,:,1) = nanmean(grandAverage(:,:,:,1),3);
                obj.grandAverages(:,:,2) = nanmean(grandAverage(:,:,:,2),3);
                obj.grandAveragesSpectrogram = nanmean(grandAverageSpectrogram(:,:,:,:),4);
                obj.grandAveragesSpectrogramClass(:,:,:,1) = nanmean(grandAverageSpectrogramPerClass(:,:,:,:,1),4);
                obj.grandAveragesSpectrogramClass(:,:,:,2) = nanmean(grandAverageSpectrogramPerClass(:,:,:,:,2),4);
                obj.changed = true;
            end
        end
        
        function answer = shouldComputeGrandAverage(obj)
            answer = obj.recompute;
            if ~answer
                for sessionIndex = 1:length(obj.EEGSessionsData)
                    if obj.EEGSessionsData{sessionIndex}.shouldComputeGrandAverage() 
                        answer = true;
                    end
                end
            end
        end
        
        %% Display
        function displayGrandAverage(obj, labels, figureSaver)
            disp('Display Grand Average');
            for sessionIndex = 1:length(obj.EEGSessionsData)
                disp(num2str(obj.EEGSessionsData{sessionIndex}.sessionID));
                figureSaver.folderExtension = [obj.subjectID '/' obj.EEGSessionsData{sessionIndex}.sessionID];
                obj.EEGSessionsData{sessionIndex}.displayGrandAveragePerRun(labels, figureSaver);
            end
        end
        
        function displayGrandGrandAverage(obj, labels, figureSaver)
            disp('Display Grand Average');
            for sessionIndex = 1:length(obj.EEGSessionsData)
                disp(num2str(obj.EEGSessionsData{sessionIndex}.sessionID));
                figureSaver.folderExtension = [obj.subjectID '/' obj.EEGSessionsData{sessionIndex}.sessionID];
                obj.EEGSessionsData{sessionIndex}.displayGrandGrandAverage(labels, figureSaver);
            end
        end
        
        function displayGrandAverageTopoplot(obj, frequenciesToPlot, labels, figureSaver)
            disp(['Display Grand Average Topoplot']);
            for sessionIndex = 1:length(obj.EEGSessionsData)
                disp(num2str(obj.EEGSessionsData{sessionIndex}.sessionID));
                figureSaver.folderExtension = [obj.subjectID '/' obj.EEGSessionsData{sessionIndex}.sessionID];
                obj.EEGSessionsData{sessionIndex}.displayGrandAveragePerRunTopoplot(frequenciesToPlot, labels, figureSaver);
            end
        end
        
        function displaySpectrogram(obj, usedEvents, labels, figureSaver)
            disp('Display average spectrogram Per Run');
            for sessionIndex = 1:length(obj.EEGSessionsData)
                disp(num2str(obj.EEGSessionsData{sessionIndex}.sessionID));
                figureSaver.folderExtension = [obj.subjectID '/' obj.EEGSessionsData{sessionIndex}.sessionID];
                obj.EEGSessionsData{sessionIndex}.displaySpectrogramPerRun(usedEvents, labels, figureSaver);
            end
        end
        
        function displayRunsAveragedSpectrogram(obj, usedEvents, psdProperties, labels, figureSaver)
            disp('Display average spectrogram across runs');
            for sessionIndex = 1:length(obj.EEGSessionsData)
                disp(num2str(obj.EEGSessionsData{sessionIndex}.sessionID));
                figureSaver.folderExtension = [obj.subjectID '/' obj.EEGSessionsData{sessionIndex}.sessionID];
                obj.EEGSessionsData{sessionIndex}.displayRunsAveragedSpectrogram(usedEvents, psdProperties, labels, figureSaver);
            end
        end
        
        function displayRunsAveragedSpectrogramPerClass(obj, psdProperties, labels, figureSaver)
            epochsPerTrial = size(obj.grandAveragesSpectrogramClass(:,:,:,1), 3);
            time = (0:1:epochsPerTrial-1)/psdProperties.epochFrequency;
            properties = struct('time', time, 'frequencies', psdProperties.frequenciesToStudy);
            figure('Name', 'Average spectrogram over all runs 1', 'WindowStyle', 'docked');
            grandGrandAverageSpectrogram = permute(obj.grandAveragesSpectrogramClass(:,:,:,1), [3,2,1]);
            SpectrogramDisplayer().plotAllChannelsWithEvents(...
                grandGrandAverageSpectrogram, ...
                properties, ...
                {obj.EEGSessionsData{1}.EEGRunsData{1}.channelsData.labels},...
                [],...
                labels(2), ...
                labels(2));
            figureSaver.saveCurrentFigure(['AverageRunSpectrogram' labels{2}]);
            
            figure('Name', 'Average spectrogram over all runs 2', 'WindowStyle', 'docked');
            grandGrandAverageSpectrogram = permute(obj.grandAveragesSpectrogramClass(:,:,:,2), [3,2,1]);
            SpectrogramDisplayer().plotAllChannelsWithEvents(...
                grandGrandAverageSpectrogram, ...
                properties, ...
                {obj.EEGSessionsData{1}.EEGRunsData{1}.channelsData.labels},...
                [],...
                labels(1), ...
                labels(1));
            figureSaver.saveCurrentFigure(['AverageRunSpectrogram' labels{1}]);
        end
    end
end