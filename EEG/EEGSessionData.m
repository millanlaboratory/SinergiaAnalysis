classdef EEGSessionData < handle
    properties
        sessionID
        EEGRunsData
        grandAveragesPerRun
        grandAveragesPerRunPerEpoch
        grandAveragesPerRunPerEpochPerClass
        frequencies
        nbOfCalibrationRuns = 0
        nbOfOnlineRuns = 0
        isFlexion = false
        isExtension = false
        minEpochsPerTrial = -1
    end
    
    methods
        %% Load & save
        function obj = EEGSessionData(sessionID)
            obj.sessionID = sessionID;
            if contains(obj.sessionID, 'flex')
                obj.isFlexion = true;
            elseif contains(obj.sessionID, 'ext')
                obj.isExtension = true;
            end
        end
        
        function loadSession(obj, dataFolder)
            filenamesEEG = obj.getEEGFilenames(dataFolder);
            obj.EEGRunsData = cell(length(filenamesEEG),1);
            discardedRuns = [];
            for indexRun = 1:length(filenamesEEG)
                obj.EEGRunsData{indexRun} = EEGRunData();
                try
                    obj.EEGRunsData{indexRun}.load(filenamesEEG{indexRun});
                catch 
                    discardedRuns(end+1) = indexRun;
                end
                if obj.EEGRunsData{indexRun}.runType == EEGRunType.Calibration
                    obj.nbOfCalibrationRuns = obj.nbOfCalibrationRuns + 1;
                else
                    obj.nbOfOnlineRuns = obj.nbOfOnlineRuns + 1;
                end
            end
            obj.EEGRunsData(discardedRuns) = [];
        end
        
        function filenamesEEG = getEEGFilenames(obj, dataFolder)
            pathRawEEG      = [dataFolder '/' obj.sessionID];
            filesEEG        = dir([pathRawEEG '/*.gdf']);
            addpath(pathRawEEG);
            filenamesEEG    = {filesEEG.name};
        end
        
        function save(obj, filename)
            save(filename, 'obj');
        end
        
        %% PSD
        function computePSDForAllRuns(obj, psdProperties, spatialFilter)
            for indexRun = 1:length(obj.EEGRunsData)
                disp(['Run ' num2str(indexRun)]);
                obj.EEGRunsData{indexRun}.computePSDForAllChannels(psdProperties, spatialFilter);
            end 
        end
        
        function answer = shouldComputePSDForAllRuns(obj)
            answer = false;
            for indexRun = 1:length(obj.EEGRunsData)
                if isempty(obj.EEGRunsData{indexRun}.psdData)
                    answer = true;
                end
            end
        end
        
        function computePSDForAllOfflineRuns(obj, psdProperties, spatialFilter)
            for indexRun = 1:length(obj.EEGRunsData)
                disp(['Run ' num2str(indexRun)]);
                if obj.EEGRunsData{indexRun}.runType == EEGRunType.Calibration
                    obj.EEGRunsData{indexRun}.computePSDForAllChannels(psdProperties, spatialFilter);
                end
            end 
        end
        
        function answer = shouldComputePSDForAllOfflineRuns(obj)
            answer = false;
            for indexRun = 1:length(obj.EEGRunsData)
                if obj.EEGRunsData{indexRun}.runType == EEGRunType.Calibration
                    if isempty(obj.EEGRunsData{indexRun}.psdData)
                        answer = true;
                    end
                end
            end
        end
        
        function [allTrialPSD, usedRunsIndex] = getAllTrialsPSD(obj, usedEvents)
            allTrialPSD     = [];
            usedRunsIndex   = [];
            for indexRun = 1:length(obj.EEGRunsData)
                if obj.EEGRunsData{indexRun}.runType == EEGRunType.Calibration
                    usedRunsIndex = [usedRunsIndex indexRun];
                    obj.EEGRunsData{indexRun}.extractEvents(usedEvents);
                    obj.EEGRunsData{indexRun}.extractNormalizePSDPerTrial();
                    allTrialPSD = cat(2, allTrialPSD, obj.EEGRunsData{indexRun}.psdPerTrial);
                end
            end
        end
        
        %% Grand Averages
        function computeGrandAveragePerRun(obj, usedEvents)
            obj.grandAveragesPerRun = cell(obj.nbOfCalibrationRuns, 2);
            currentGrandAveragedRun = 1;
            for runIndex = 1:length(obj.EEGRunsData)
                if obj.EEGRunsData{runIndex}.runType == EEGRunType.Calibration
                    disp(['Run ' num2str(runIndex)]);
                    obj.computeGrandAverageForRun(runIndex, currentGrandAveragedRun, usedEvents);
                    currentGrandAveragedRun = currentGrandAveragedRun + 1;
                end
            end
        end
        
        function computeGrandAverageSpectrogramPerRun(obj, usedEvents)
            obj.grandAveragesPerRunPerEpoch = cell(obj.nbOfCalibrationRuns, 1);
            currentGrandAveragedRun = 1;
            for runIndex = 1:length(obj.EEGRunsData)
                if obj.EEGRunsData{runIndex}.runType == EEGRunType.Calibration
                    disp(['Run ' num2str(runIndex)]);
                    obj.computeGrandAverageSpectrogramForRun(runIndex, currentGrandAveragedRun, usedEvents);
                    currentGrandAveragedRun = currentGrandAveragedRun + 1;
                end
            end
            currentGrandAveragedRun = 1;
            for runIndex = 1:length(obj.EEGRunsData)
                if obj.EEGRunsData{runIndex}.runType == EEGRunType.Calibration
                    currentGrandAverageClass = obj.grandAveragesPerRunPerEpoch{currentGrandAveragedRun};
                    currentGrandAverageClass(:,:,obj.minEpochsPerTrial:end) = [];
                    obj.grandAveragesPerRunPerEpoch{currentGrandAveragedRun} = currentGrandAverageClass;
                    currentGrandAveragedRun = currentGrandAveragedRun + 1;
                end
            end
        end
        
        function computeGrandAverageForRun(obj, runIndex, currentGrandAveragedRun, usedEvents)
            obj.EEGRunsData{runIndex}.extractEvents(usedEvents);
            obj.EEGRunsData{runIndex}.extractNormalizePSDPerTrial();
            if obj.isFlexion
                [grandAverageClass1, ~, obj.frequencies] = ...
                    obj.EEGRunsData{runIndex}.getGrandAverageForClassPerTrial(usedEvents.Flexion, usedEvents);
                [spectrogramClass1, ~, obj.frequencies] = ...
                    obj.EEGRunsData{runIndex}.getSpectrogramForClassPerTrial(usedEvents.Flexion, usedEvents);
            elseif obj.isExtension
                [grandAverageClass1, ~, obj.frequencies] = ...
                    obj.EEGRunsData{runIndex}.getGrandAverageForClassPerTrial(usedEvents.Extension, usedEvents);
                [spectrogramClass1, ~, obj.frequencies] = ...
                    obj.EEGRunsData{runIndex}.getSpectrogramForClassPerTrial(usedEvents.Extension, usedEvents);
            end
            [grandAverageClass2, ~, ~] = ...
                obj.EEGRunsData{runIndex}.getGrandAverageForClassPerTrial(usedEvents.Rest, usedEvents);
            [spectrogramClass2, ~, obj.frequencies] = ...
                obj.EEGRunsData{runIndex}.getSpectrogramForClassPerTrial(usedEvents.Rest, usedEvents);
            obj.grandAveragesPerRun{currentGrandAveragedRun,1} = mean(grandAverageClass1, 3);
            obj.grandAveragesPerRun{currentGrandAveragedRun,2} = mean(grandAverageClass2, 3);
            
            obj.grandAveragesPerRunPerEpochPerClass{currentGrandAveragedRun,1} = squeeze(mean(spectrogramClass1,2));
            obj.grandAveragesPerRunPerEpochPerClass{currentGrandAveragedRun,2} = squeeze(mean(spectrogramClass2,2));
        end
        
        function computeGrandAverageSpectrogramForRun(obj, runIndex, currentGrandAveragedRun, usedEvents)
            obj.EEGRunsData{runIndex}.extractEvents(usedEvents);
            obj.EEGRunsData{runIndex}.extractNormalizePSDPerTrial();
            [grandAverage, ~, obj.frequencies] = obj.EEGRunsData{runIndex}.getGrandAveragePerTrial();
            if obj.minEpochsPerTrial == -1 || size(grandAverage,3) < obj.minEpochsPerTrial
                obj.minEpochsPerTrial = size(grandAverage,3);
            end
            obj.grandAveragesPerRunPerEpoch{currentGrandAveragedRun} = grandAverage;
        end
        
        function answer = shouldComputeGrandAverage(obj)
            answer = false;
            if isempty(obj.grandAveragesPerRun)
                answer = true;
            end
        end
        
        function [grandAverage, usedRunsIndex] = computeGrandAverageOverAllRuns(obj, usedEvents, psdProperties)
            [allTrialPSD, usedRunsIndex] = obj.getAllTrialsPSD(usedEvents);
            epochsPerTrial = size(allTrialPSD,4);
            grandAverage = NaN(length(psdProperties.frequenciesToStudy), epochsPerTrial, obj.EEGRunsData{usedRunsIndex(1)}.nbOfChannels);
            for channel = 1:obj.EEGRunsData{end}.nbOfChannels
                trialPSDForOneChannel = squeeze(allTrialPSD(channel,:,:,:));
                if length(size(trialPSDForOneChannel)) > 2
                    grandAverage(:,:,channel) = mean(trialPSDForOneChannel,1);
                else
                    grandAverage(:,:,channel) = trialPSDForOneChannel;
                end
            end 
        end
        
        %% Display & plots
        function displayGrandAveragePerRunTopoplot(obj, frequenciesToPlot, labels, figureSaver)
            for indexRun = 1:length(obj.grandAveragesPerRun)
                disp(['Run ' num2str(indexRun)]);
                EEGDisplayer.topoplotGrandAverageOfTwoClasses(obj.grandAveragesPerRun{indexRun, 1}, ...
                    obj.grandAveragesPerRun{indexRun, 2}, ...
                    obj.frequencies, ...
                    frequenciesToPlot, ...
                    obj.EEGRunsData{indexRun}.channelsData64, ...
                    labels)
                figureSaver.saveCurrentFigure(['TopoplotRun_' num2str(indexRun)]);
            end
        end
        
        function displayGrandAveragePerRun(obj, labels, figureSaver)
            for indexRun = 1:size(obj.grandAveragesPerRun,1)
                figure('Name', ['Grand Average run' num2str(indexRun)], 'WindowStyle', 'docked'); clf;
                EEGDisplayer.plotClassesGrandAverage(obj.grandAveragesPerRun{indexRun,1}, ...
                    obj.grandAveragesPerRun{indexRun,2}, ...
                    obj.frequencies, ...
                    {obj.EEGRunsData{indexRun}.channelsData.labels}, ...
                    labels)
                figureSaver.saveCurrentFigure(['GrandAverageRun_' num2str(indexRun)]);
            end
        end
        
        function displayGrandGrandAverage(obj, labels, figureSaver)
            grandGrandAverage1 = nan([size(obj.grandAveragesPerRun{1,1}) size(obj.grandAveragesPerRun,1)]);
            grandGrandAverage2 = nan([size(obj.grandAveragesPerRun{1,2}) size(obj.grandAveragesPerRun,1)]);
            for indexRun = 1:size(obj.grandAveragesPerRun,1)
                grandGrandAverage1(:,:,indexRun) = obj.grandAveragesPerRun{indexRun,1};
                grandGrandAverage2(:,:,indexRun) = obj.grandAveragesPerRun{indexRun,2};
            end
            grandGrandAverage1 = mean(grandGrandAverage1,3);
            grandGrandAverage2 = mean(grandGrandAverage2,3);
            figure('Name', 'Grand Grand Average', 'WindowStyle', 'docked'); clf;
            EEGDisplayer.plotClassesGrandAverage(grandGrandAverage1, ...
                grandGrandAverage2, ...
                obj.frequencies, ...
                {obj.EEGRunsData{1}.channelsData.labels}, ...
                labels)
            figureSaver.saveCurrentFigure('GrandGrandAverage');
        end
        
        function displaySpectrogramPerRun(obj, usedEvents, classLabels, figureSaver)
            currentCalibrationRunIndex = 1;
            for indexRun = 1:length(obj.EEGRunsData)
                if obj.EEGRunsData{indexRun}.runType == EEGRunType.Calibration
                    disp(['Run ' num2str(indexRun)]);
                    obj.EEGRunsData{indexRun}.extractEvents(usedEvents);
                    obj.EEGRunsData{indexRun}.extractNormalizePSDPerTrial();
                    properties = struct('time', [], 'frequencies', []);
                    [grandAverage, properties.time, properties.frequencies] = obj.EEGRunsData{indexRun}.getGrandAverage();
                    commandTimes = obj.EEGRunsData{indexRun}.getSpecificEventTypeTimes(usedEvents.startCommand, usedEvents.occurences, usedEvents.maxOccurences);
                    spectrogramLegend = cell(length(commandTimes.start),1);
                    for index = 1:length(commandTimes.start)
                        spectrogramLegend{index} = classLabels{(mod(index,2) == 0) + 1};
                    end
                    figure('Name', ['Average Spectrogram Run' num2str(indexRun)], 'WindowStyle', 'docked');
                    SpectrogramDisplayer().plotAllChannelsWithEvents(...
                        grandAverage, ...
                        properties, ...
                        {obj.EEGRunsData{indexRun}.channelsData.labels},...
                        commandTimes.start,...
                        spectrogramLegend, ...
                        classLabels);
                    figureSaver.saveCurrentFigure(['AveragedSpectrogramRun_' num2str(currentCalibrationRunIndex)]);
                    currentCalibrationRunIndex = currentCalibrationRunIndex + 1;
                end
            end
        end
        
        function displayRunsAveragedSpectrogram(obj, usedEvents, psdProperties, classLabels, figureSaver)
            [grandAverage, usedRunsIndex] = obj.computeGrandAverageOverAllRuns(usedEvents, psdProperties);
            epochsPerTrial = size(grandAverage, 2);
            time = (0:1:epochsPerTrial-1)/psdProperties.epochFrequency;
            properties = struct('time', time, 'frequencies', psdProperties.frequenciesToStudy);
            commandTimes = obj.EEGRunsData{usedRunsIndex(1)}.getSpecificEventTypeTimes(usedEvents.startCommand, usedEvents.occurences, usedEvents.maxOccurences);
            spectrogramLegend = cell(length(commandTimes.start),1);
            for index = 1:length(commandTimes.start)
                spectrogramLegend{index} = classLabels{(mod(index,2) == 0) + 1};
            end
            figure('Name', 'Average spectrogram over all runs', 'WindowStyle', 'docked');
            SpectrogramDisplayer().plotAllChannelsWithEvents(...
                grandAverage, ...
                properties, ...
                {obj.EEGRunsData{usedRunsIndex(1)}.channelsData.labels},...
                commandTimes.start,...
                spectrogramLegend, ...
                classLabels);
            figureSaver.saveCurrentFigure('AverageRunSpectrogram');
        end
        
        function displayRunsAveragedSpectrogramPerClass(obj, usedEvents, psdProperties, classLabels, figureSaver)
            [grandAverage, usedRunsIndex] = obj.computeGrandAverageOverAllRuns(usedEvents, psdProperties);
            epochsPerTrial = size(grandAverage, 2);
            time = (0:1:epochsPerTrial-1)/psdProperties.epochFrequency;
            properties = struct('time', time, 'frequencies', psdProperties.frequenciesToStudy);
            commandTimes = obj.EEGRunsData{usedRunsIndex(1)}.getSpecificEventTypeTimes(usedEvents.startCommand, usedEvents.occurences, usedEvents.maxOccurences);
            spectrogramLegend = cell(length(commandTimes.start),1);
            for index = 1:length(commandTimes.start)
                spectrogramLegend{index} = classLabels{(mod(index,2) == 0) + 1};
            end
            figure('Name', 'Average spectrogram over all runs', 'WindowStyle', 'docked');
            SpectrogramDisplayer().plotAllChannelsWithEvents(...
                grandAverage, ...
                properties, ...
                {obj.EEGRunsData{usedRunsIndex(1)}.channelsData.labels},...
                commandTimes.start,...
                spectrogramLegend, ...
                classLabels);
            figureSaver.saveCurrentFigure('AverageRunSpectrogram');
        end
    end
end