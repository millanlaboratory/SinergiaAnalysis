classdef EEGRunData < handle
    properties
        rawData
        psdData
        psdPerTrial
        allTrialPSDPerTrial
        mvt
        rest
        spectMvt
        spectRest
        loaded = false
        psdProperties
        spectProperties
        sampleBasedEvents
        timeBasedEvents
        allSampleBasedEvents
        uniqueEvents
        nbOfChannels
        sampleRate
        runType
        runNumber = 0
        channelsData
        channelsData64
        isFlexion = false
        isExtension = false
        labels = {}
    end
    
    methods
        function load(obj, filename)
            if contains(filename, 'flex')
                obj.isFlexion = true;
                obj.labels{1} = 'Flexion';
            elseif contains(filename, 'ext')
                obj.isExtension = true;
                obj.labels{1} = 'Extension';
            end
            obj.labels{end+1} = 'Rest';
            [obj.rawData, header] = sload(filename);
            obj.rawData(:,17)   = [];
            
            obj.nbOfChannels    = header.NS-1;
            obj.sampleRate      = header.SampleRate;
            obj.allSampleBasedEvents = header.EVENT;
            if contains(filename, 'offline')
                obj.runType = EEGRunType.Calibration;
            elseif contains(filename, 'online')
                obj.runType = EEGRunType.Online;
            end
            obj.channelsData = load('chanlocs16.mat');
            obj.channelsData = obj.channelsData.chanlocs16;
            obj.channelsData64 = load('chanlocs64.mat');
            obj.channelsData64 = obj.channelsData64.chanlocs;
            obj.loaded = true;
        end
        
        function saveRun(obj, folder, filename)
            save([folder '/' filename], 'obj');
        end
        
        function newRun = copy(obj)
            newRun = EEGRunData();
            newRun.rawData = obj.rawData;
            newRun.psdData = obj.psdData;
            newRun.psdPerTrial = obj.psdPerTrial;
            newRun.allTrialPSDPerTrial = obj.allTrialPSDPerTrial;
            newRun.mvt = obj.mvt;
            newRun.rest = obj.rest;
            newRun.spectMvt = obj.spectMvt;
            newRun.spectRest = obj.spectRest;
            newRun.loaded = obj.loaded;
            newRun.psdProperties = obj.psdProperties;
            newRun.spectProperties = obj.spectProperties;
            newRun.sampleBasedEvents = obj.sampleBasedEvents;
            newRun.timeBasedEvents = obj.timeBasedEvents;
            newRun.allSampleBasedEvents = obj.allSampleBasedEvents;
            newRun.uniqueEvents = obj.uniqueEvents;
            newRun.nbOfChannels = obj.nbOfChannels;
            newRun.sampleRate = obj.sampleRate;
            newRun.runType = obj.runType;
            newRun.runNumber = obj.runNumber;
            newRun.channelsData = obj.channelsData;
            newRun.channelsData64 = obj.channelsData64;
            newRun.isFlexion = obj.isFlexion;
            newRun.isExtension = obj.isExtension;
            newRun.labels = obj.labels;
        end
        
        
        %% Events extraction
        function extractEvents(obj, usedEvents)
            obj.extractSampleBasedEvents(usedEvents);
            obj.extractTimeBasedEvents();
            if length(obj.sampleBasedEvents.start) > length(obj.sampleBasedEvents.startBaseline)
                warning('More trials than baselines');
                diffStops = obj.sampleBasedEvents.start*ones(1,length(obj.sampleBasedEvents.stopBaseline)) - obj.sampleBasedEvents.stopBaseline';
                obj.sampleBasedEvents.stopBaseline = obj.sampleBasedEvents.stopBaseline(sum(diffStops > 0,2));
                obj.sampleBasedEvents.startBaseline = obj.sampleBasedEvents.startBaseline(sum(diffStops > 0,2));
            end
            if length(obj.timeBasedEvents.start) > length(obj.timeBasedEvents.startBaseline)
                warning('More trials than baselines');
                diffStops = obj.timeBasedEvents.start'*ones(1,length(obj.timeBasedEvents.stopBaseline)) - obj.timeBasedEvents.stopBaseline;
                obj.timeBasedEvents.stopBaseline = obj.timeBasedEvents.stopBaseline(sum(diffStops > 0,2));
                obj.timeBasedEvents.startBaseline = obj.timeBasedEvents.startBaseline(sum(diffStops > 0,2));
                diffStops = obj.timeBasedEvents.startTime'*ones(1,length(obj.timeBasedEvents.stopTimeBaseline)) - obj.timeBasedEvents.stopTimeBaseline;
                obj.timeBasedEvents.stopTimeBaseline = obj.timeBasedEvents.stopTimeBaseline(sum(diffStops > 0,2));
                obj.timeBasedEvents.startTimeBaseline = obj.timeBasedEvents.startTimeBaseline(sum(diffStops > 0,2));
            end
        end
        
        function extractSampleBasedEvents(obj, usedEvents)
            obj.cleanEvents(usedEvents);
            obj.sampleBasedEvents = struct('start', [], 'stop', [], 'startBaseline', [], 'stopBaseline', []);
            
            if isfield(usedEvents, 'stopTime')
                obj.sampleBasedEvents.start = obj.allSampleBasedEvents.POS(...
                        obj.allSampleBasedEvents.TYP == usedEvents.start);
                obj.sampleBasedEvents.stop = obj.allSampleBasedEvents.POS(...
                        obj.allSampleBasedEvents.TYP == usedEvents.start) +...
                        floor(usedEvents.stopTime*obj.sampleRate);
            else
                obj.sampleBasedEvents.start = obj.allSampleBasedEvents.POS(...
                    obj.allSampleBasedEvents.TYP == usedEvents.Start);
                obj.sampleBasedEvents.stop = obj.sampleBasedEvents.start + ...
                obj.allSampleBasedEvents.DUR(obj.allSampleBasedEvents.TYP == usedEvents.Start);
                if length(obj.sampleBasedEvents.stop) > length(obj.sampleBasedEvents.start)
                    a = ones(1,length(obj.sampleBasedEvents.start));
                    b = obj.sampleBasedEvents.stop * a;
                    [~, index] = min( abs(b - obj.sampleBasedEvents.start'));
                    obj.sampleBasedEvents.stop = obj.sampleBasedEvents.stop(index);
                end
            end
            if sum(obj.sampleBasedEvents.stop < obj.sampleBasedEvents.start)
                error('Stop events should be after start events');
            end
            obj.extractSampleBasedBaselineEvents(usedEvents);
        end
        
        function cleanEvents(obj, usedEvents)
            if obj.isExtension && ~any(obj.allSampleBasedEvents.TYP == usedEvents.Extension)
                currentExtensionEvent = 1;
                for indexEvent = 1:length(obj.allSampleBasedEvents.TYP) - 1
                    if obj.allSampleBasedEvents.TYP(indexEvent) == usedEvents.OldExtension && obj.allSampleBasedEvents.TYP(indexEvent + 1) == usedEvents.OldExtension
                        obj.allSampleBasedEvents.TYP(indexEvent) = usedEvents.Extension;
                        currentExtensionEvent = currentExtensionEvent + 1;
                    end
                end
            end
            eventsToKeep = zeros(1, length(obj.allSampleBasedEvents.TYP));
            eventNames = fieldnames(usedEvents);
            for indexField = 1: length(eventNames)
                event = getfield(usedEvents, eventNames{indexField});
                eventsToKeep = eventsToKeep | (obj.allSampleBasedEvents.TYP == event)';
            end
            
            obj.allSampleBasedEvents.TYP(~eventsToKeep) = [];
            obj.allSampleBasedEvents.POS(~eventsToKeep) = [];
            obj.allSampleBasedEvents.DUR(~eventsToKeep) = [];
        end
        
        function extractSampleBasedBaselineEvents(obj, usedEvents)
            obj.sampleBasedEvents.startBaseline = obj.allSampleBasedEvents.POS(...
                obj.allSampleBasedEvents.TYP == usedEvents.Baseline);
            obj.sampleBasedEvents.stopBaseline = obj.sampleBasedEvents.startBaseline +...
                obj.allSampleBasedEvents.DUR(obj.allSampleBasedEvents.TYP == usedEvents.Baseline);
        end
        
        function extractTimeBasedEvents(obj)
            obj.timeBasedEvents = struct('start',[], 'stop',[],...
                'startBaseline',[], 'stopBaseline', [],...
                'startTime',[], 'stopTime', [],...
                'startTimeBaseline',[], 'stopTimeBaseline', []);
            dataTime = 0:(1/obj.sampleRate):((length(obj.rawData)-1)/obj.sampleRate);
            obj.timeBasedEvents.startTime   = dataTime(obj.sampleBasedEvents.start);
            obj.timeBasedEvents.stopTime    = dataTime(obj.sampleBasedEvents.stop);
            obj.timeBasedEvents.startTimeBaseline   = dataTime(obj.sampleBasedEvents.startBaseline);
            obj.timeBasedEvents.stopTimeBaseline    = dataTime(obj.sampleBasedEvents.stopBaseline);
            timeOffset      = 0.5; % s
            timeStep        = (1/obj.psdProperties.epochFrequency);
            timeLimit       = ((length(obj.rawData)-obj.sampleRate)/obj.sampleRate);
            resampledTime   = (0:timeStep:timeLimit) + timeOffset;
            [~, obj.timeBasedEvents.start] = min(abs(resampledTime' * ...
                ones(1,length(obj.timeBasedEvents.startTime)) - obj.timeBasedEvents.startTime));
            [~,  obj.timeBasedEvents.stop] = min(abs(resampledTime' * ...
                ones(1,length(obj.timeBasedEvents.stopTime)) - obj.timeBasedEvents.stopTime));
            [~,  obj.timeBasedEvents.startBaseline] = min(abs(resampledTime' * ...
                ones(1,length(obj.timeBasedEvents.startTimeBaseline)) - obj.timeBasedEvents.startTimeBaseline));
            [~, obj.timeBasedEvents.stopBaseline]   = min(abs(resampledTime' * ...
                ones(1,length(obj.timeBasedEvents.stopTimeBaseline)) - obj.timeBasedEvents.stopTimeBaseline));
        end
        
        function commandTimes = getSpecificEventTypeTimes(obj, startEvent, event, occurences)
            commandTimes = struct('start',[], 'stop',[]);
            startTrialPos = reshape(obj.allSampleBasedEvents.POS(obj.allSampleBasedEvents.TYP == startEvent),occurences,[]);
            startCommandPos = reshape(obj.allSampleBasedEvents.POS(obj.allSampleBasedEvents.TYP == event),occurences,[]) - startTrialPos;
            stopCommandPos = startCommandPos + ...
                reshape(obj.allSampleBasedEvents.DUR(obj.allSampleBasedEvents.TYP == event),occurences,[]);
            commandTimes.start = min(startCommandPos)/obj.sampleRate;
            commandTimes.stop = max(stopCommandPos)/obj.sampleRate; 
        end
        
        %% PSD
        function computePSDForAllChannels(obj, psdProperties, spatialFilter, errorLog)
            filteredData = spatialFilter.applyFilter(obj.rawData);
            obj.psdProperties = psdProperties;
            nbSamples = size(obj.rawData,1);
            sampleBasedWindow = obj.sampleRate * psdProperties.windowSize;
            sampleBasedOverlap = obj.sampleRate * psdProperties.overlap;
            nbOfEpochs = floor((nbSamples - sampleBasedWindow)/(sampleBasedWindow - sampleBasedOverlap) + 1);
            rawPSD = NaN(obj.nbOfChannels, length(psdProperties.frequenciesToStudy), nbOfEpochs);
            D = parallel.pool.DataQueue;
            afterEach(D, @updateLogMessage);
            analyzedChannel = 1;
            parfor channel = 1:obj.nbOfChannels
                send(D, channel);
                [~,~,~,rawPSD(channel,:,:)] = spectrogram(filteredData(:,channel), sampleBasedWindow, sampleBasedOverlap, ...
                    psdProperties.frequenciesToStudy, obj.sampleRate);
            end
            function updateLogMessage(~)
                logMessages = get(errorLog, 'String');
                logMessages{end+1} = ['Compute psd for channel ' num2str(analyzedChannel)];
                set(errorLog, 'String', logMessages);
                analyzedChannel = analyzedChannel + 1;
            end
            obj.psdData = 10*log10(rawPSD);
        end
        
        %% PSD Per Trial
        function extractNormalizePSDPerTrial(obj)
            epochsPerTrial  = obj.getNbEpochsPerTrial();
            epochsPerExtendedTrial  = obj.getNbEpochsPerExtendedTrial();
            obj.psdPerTrial = NaN(obj.nbOfChannels, length(obj.timeBasedEvents.start), ...
                length(obj.psdProperties.frequenciesToStudy), epochsPerTrial.max+1);
            obj.allTrialPSDPerTrial = NaN(obj.nbOfChannels, length(obj.timeBasedEvents.start), ...
                length(obj.psdProperties.frequenciesToStudy), epochsPerExtendedTrial.max+1);
            for trial = 1:length(obj.timeBasedEvents.start)
                [obj.psdPerTrial(:,trial,:,:), obj.allTrialPSDPerTrial(:,trial,:,:)] = obj.extractNormalizedTrialPSD(trial, epochsPerTrial, epochsPerExtendedTrial);
            end
        end
        
        function epochsPerTrial = getNbEpochsPerTrial(obj)
            sampleBasedWindow   = obj.sampleRate * obj.psdProperties.windowSize;
            sampleBasedOverlap  = obj.sampleRate * obj.psdProperties.overlap;
            trialDurations      = obj.sampleBasedEvents.stop-obj.sampleBasedEvents.start;
            minTrialDuration    = min(trialDurations);
            maxTrialDuration    = max(trialDurations);
            epochsPerTrial.min  = floor((minTrialDuration - sampleBasedWindow)/...
                (sampleBasedWindow - sampleBasedOverlap) + 1);
            epochsPerTrial.max      = floor((maxTrialDuration - sampleBasedWindow)/...
                (sampleBasedWindow - sampleBasedOverlap) + 1);
        end
        
        function epochsPerTrial = getNbEpochsPerExtendedTrial(obj)
            sampleBasedWindow   = obj.sampleRate * obj.psdProperties.windowSize;
            sampleBasedOverlap  = obj.sampleRate * obj.psdProperties.overlap;
            trialDurations      = obj.sampleBasedEvents.stop-obj.sampleBasedEvents.startBaseline;
            minTrialDuration    = min(trialDurations);
            maxTrialDuration    = max(trialDurations);
            epochsPerTrial.min  = floor((minTrialDuration - sampleBasedWindow)/...
                (sampleBasedWindow - sampleBasedOverlap) + 1);
            epochsPerTrial.max      = floor((maxTrialDuration - sampleBasedWindow)/...
                (sampleBasedWindow - sampleBasedOverlap) + 1);
        end
        
        function removeEvents(obj, events)
            obj.sampleBasedEvents.start(events) = [];
            obj.sampleBasedEvents.stop(events) = [];
            obj.sampleBasedEvents.startBaseline(events) = [];
            obj.sampleBasedEvents.stopBaseline(events) = [];
            obj.timeBasedEvents.start(events) = [];
            obj.timeBasedEvents.stop(events) = [];
            obj.timeBasedEvents.startBaseline(events) = [];
            obj.timeBasedEvents.stopBaseline(events) = [];
            obj.timeBasedEvents.startTime(events) = [];
            obj.timeBasedEvents.stopTime(events) = [];
            obj.timeBasedEvents.startTimeBaseline(events) = [];
            obj.timeBasedEvents.stopTimeBaseline(events) = [];
        end
        
        function [trialPSD, allTrialPSD] = extractNormalizedTrialPSD(obj, trial, epochsPerTrial, epochsPerExtendedTrial)
            trialPSD = nan(size(obj.psdData,1), size(obj.psdData,2), epochsPerTrial.max + 1);
            allTrialPSD = nan(size(obj.psdData,1), size(obj.psdData,2), epochsPerExtendedTrial.max + 1 );
            duration = obj.timeBasedEvents.stop(trial) - obj.timeBasedEvents.start(trial) + 1 - obj.psdProperties.epochFrequency;
            fullDuration = obj.timeBasedEvents.stop(trial) - obj.timeBasedEvents.startBaseline(trial) + 1 - obj.psdProperties.epochFrequency;
            trialPSD(:,:,1:duration) = obj.psdData(:,:,obj.timeBasedEvents.start(trial):obj.timeBasedEvents.stop(trial) - obj.psdProperties.epochFrequency);
            allTrialPSD(:,:,1:fullDuration) = obj.psdData(:,:,obj.timeBasedEvents.startBaseline(trial):obj.timeBasedEvents.stop(trial) - obj.psdProperties.epochFrequency);
            startBaseline = (obj.timeBasedEvents.stopBaseline(trial) - obj.timeBasedEvents.startBaseline(trial))/2 + obj.timeBasedEvents.startBaseline(trial);
            baselinePSD = squeeze(nanmean(obj.psdData(:,:,floor(startBaseline):obj.timeBasedEvents.stopBaseline(trial)),3));
            trialPSD = squeeze(trialPSD) - repmat(baselinePSD,1, 1, size(trialPSD,3));
            allTrialPSD = squeeze(allTrialPSD) - repmat(baselinePSD,1, 1, size(allTrialPSD,3));
        end
        
        %% Grand Average
        function [grandAverage, time, frequencies] = getAveragedPSDForMovementPerTrial(obj, usedEvents)
            if obj.isFlexion
                [grandAverage, time, frequencies] = ...
                    obj.getGrandAverageForClassPerTrial(usedEvents.Flexion, usedEvents);
            elseif obj.isExtension
                [grandAverage, time, frequencies] = ...
                    obj.getGrandAverageForClassPerTrial(usedEvents.Extension, usedEvents);
            end
        end
        
        function [grandAverage, time, frequencies] = getAveragedPSDForRestPerTrial(obj, usedEvents)
            [grandAverage, time, frequencies] = ...
                    obj.getGrandAverageForClassPerTrial(usedEvents.Rest, usedEvents);
        end
        
        function [Spectrogram, time, frequencies] = getSpectrogramForMovementPerTrial(obj, usedEvents)
            if obj.isFlexion
                [Spectrogram, time, frequencies] = ...
                    obj.getSpectrogramForClassPerTrial(usedEvents.Flexion, usedEvents);
            elseif obj.isExtension
                [Spectrogram, time, frequencies] = ...
                    obj.getSpectrogramForClassPerTrial(usedEvents.Extension, usedEvents);
            end
        end
        
        function [grandAverage, time, frequencies] = getSpectrogramForRestPerTrial(obj, usedEvents)
            [grandAverage, time, frequencies] = ...
                    obj.getSpectrogramForClassPerTrial(usedEvents.Rest, usedEvents);
        end
        
        function [grandAverage, time, frequencies] = getGrandAverageForClassPerTrial(obj, classEvent, usedEvents)
            startIndices    = find(obj.allSampleBasedEvents.TYP == usedEvents.Start);
            labels          = obj.allSampleBasedEvents.TYP(startIndices - 1);
            allTrials       = obj.allSampleBasedEvents.POS(startIndices);
            eventsToRemove = [];
            for indexEvent = 1:length(allTrials)
                if sum(allTrials(indexEvent) == obj.sampleBasedEvents.start) == 0
                    eventsToRemove = [eventsToRemove indexEvent];
                end
            end
            labels(eventsToRemove) = [];
            epochsPerTrial = size(obj.psdPerTrial,4);
            grandAverage = squeeze(nanmean(obj.psdPerTrial(:,labels == classEvent,:,:),4));
            time = (0:1:epochsPerTrial-1)/obj.psdProperties.epochFrequency;
            frequencies = obj.psdProperties.frequenciesToStudy;
        end
        
        function [Spectrogram, time, frequencies] = getSpectrogramForClassPerTrial(obj, classEvent, usedEvents)
            startIndices    = find(obj.allSampleBasedEvents.TYP == usedEvents.Start);
            labels          = obj.allSampleBasedEvents.TYP(startIndices - 1);
            allTrials       = obj.allSampleBasedEvents.POS(startIndices);
            eventsToRemove = [];
            for indexEvent = 1:length(allTrials)
                if sum(allTrials(indexEvent) == obj.sampleBasedEvents.start) == 0
                    eventsToRemove = [eventsToRemove indexEvent];
                end
            end
            labels(eventsToRemove) = [];
            epochsPerTrial = size(obj.allTrialPSDPerTrial,4);
            Spectrogram = squeeze(obj.allTrialPSDPerTrial(:,labels == classEvent,:,:));
            time = (0:1:epochsPerTrial-1)/obj.psdProperties.epochFrequency;
            frequencies = obj.psdProperties.frequenciesToStudy;
        end
        
        function [grandAverage, time, frequencies] = getGrandAveragePerTrial(obj)
            epochsPerTrial = size(obj.psdPerTrial,4);
            grandAverage = squeeze(nanmean(obj.psdPerTrial,2));
            time = (0:1:epochsPerTrial-1)/obj.psdProperties.epochFrequency;
            frequencies = obj.psdProperties.frequenciesToStudy;
        end
        
        function [grandAverage, time, frequencies] = getGrandAverage(obj)
            epochsPerTrial = size(obj.psdPerTrial,4);
            grandAverage = NaN(length(obj.psdProperties.frequenciesToStudy), epochsPerTrial, obj.nbOfChannels);
            for channel = 1:obj.nbOfChannels
                trialPSDForOneChannel = squeeze(obj.psdPerTrial(channel,:,:,:));
                if length(size(trialPSDForOneChannel)) > 2
                    grandAverage(:,:,channel) = nanmean(trialPSDForOneChannel,1);
                else
                    grandAverage(:,:,channel) = trialPSDForOneChannel;
                end
            end
            time = (0:1:epochsPerTrial-1)/obj.psdProperties.epochFrequency;
            frequencies = obj.psdProperties.frequenciesToStudy;
        end
        
        function cleanRun(obj)
            obj.rawData = [];
            obj.psdData = [];
            obj.psdPerTrial = [];
            obj.allTrialPSDPerTrial = [];
        end
    end
end