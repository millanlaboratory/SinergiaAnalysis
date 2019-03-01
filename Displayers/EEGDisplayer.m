classdef EEGDisplayer
    %EEGDISPLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        %% Discriminancy map
        function displayDiscriminancyMap(eegRun)
            resolution = 10;
            averagedMvt = zeros(size(eegRun.mvt,1),size(eegRun.mvt,2), floor(size(eegRun.mvt,3)/resolution));
            averagedRest = zeros(size(eegRun.rest,1),size(eegRun.rest,2), floor(size(eegRun.rest,3)/resolution));
            for frequencyIndex = 1:size(averagedMvt,3)
                averagedMvt(:,:,frequencyIndex) = nanmean(eegRun.mvt(:,:,(frequencyIndex-1)*resolution+1:frequencyIndex*resolution),3);
                averagedRest(:,:,frequencyIndex) = nanmean(eegRun.rest(:,:,(frequencyIndex-1)*resolution+1:frequencyIndex*resolution),3);
            end
            [row, ~] = find(squeeze(any(isnan(averagedMvt),1)));
            averagedMvt(:,unique(row),:) = [];
            [row, ~] = find(squeeze(any(isnan(averagedRest),1)));
            averagedRest(:,unique(row),:) = [];
            labels = cell(size(averagedMvt,2) + size(averagedRest,2), 1);
            for labelIndex = 1:size(averagedMvt,2)
                labels{labelIndex} = 'Movement';
            end
            for labelIndex = 1:size(averagedRest,2)
                labels{labelIndex + size(averagedMvt,2)} = 'Rest';
            end
            discriminancyMap = zeros(size(averagedMvt,1), size(averagedMvt,3));
            for channel = 1:size(averagedMvt,1)
                for frequency = 1:size(averagedMvt,3)
                    [index,featureScore] = feature_rank([averagedMvt(channel, :, frequency) averagedRest(channel, :, frequency)], labels');
                    discriminancyMap(channel, frequency) = featureScore;
                end
            end
            EEGDisplayer.plotPDiscriminancyMap(discriminancyMap, 4:1:size(averagedMvt,3)+4, {eegRun.channelsData.labels})
        end
        
        function plotPDiscriminancyMap(discriminancyMap, frequencies, channelLabels)
            figure('Name', 'Discriminancy Map', 'WindowStyle', 'docked');
            imagesc(discriminancyMap, [0, 0.5]);
            colormap(gray);
            xticks(1:2:length(frequencies)*2+1)
            xticklabels(frequencies(1:2:end))
            xlabel('Frequency [Hz]')
            yticks(1:length(channelLabels));
            yticklabels(channelLabels)
            ylabel('Channel')
            title('Discriminancy map')
            colorbar()
        end
        
        %% Color map
        function plotPSDForTwoClasses(PSDClass1, PSDClass2,...
            frequencies, channelLabels, classLabels)
            subplot(2,2,1)
            EEGDisplayer.plotPSD(PSDClass1, frequencies, channelLabels, ['PSD for ' classLabels{1}]);
            subplot(2,2,2)
            EEGDisplayer.plotPSD(PSDClass2, frequencies, channelLabels, ['PSD for ' classLabels{2}]);
            subplot(2,2,3)
            diffPSDClasses = abs(PSDClass1 - PSDClass2);
            EEGDisplayer.plotPSD(diffPSDClasses, frequencies, channelLabels, ...
                ['PSD absolute difference between ' classLabels{1} ' and ' classLabels{2}]);
            subplot(2,2,4)
            EEGDisplayer.plotColorBar()
        end


        function plotPSD(PSDs, frequencies, channels, plotTitle)
            imagesc(frequencies, 1:length(channels), PSDs);
            xlabel('Frequency [hz]')
            ylabel('Channel')
            title(plotTitle)  
            colormap jet;
            yticks(1:length(channels));
            yticklabels(channels)
            caxis([-5 5])
        end

        function plotColorBar()
            axis off
            xl = xlim;
            c = colorbar;
            c.Position(1) = (xl(2) + xl(1)) / 2 + 0.1 * 2; % centered
            c.Position(3) = (xl(2)-xl(1)) * 0.1; % width
            caxis([-5 5])
        end 
        
        %% Topoplot
        function topoplotPSDOfTwoClasses(PSDClass1, PSDClass2,...
            frequencies, frequenciesToPlot, chanlocs16, classLabels)
            figure('Name', 'Topoplot', 'WindowStyle', 'docked'); clf;
            EEGDisplayer.topoplotPSD(PSDClass1, frequencies, frequenciesToPlot, chanlocs16, 1, classLabels{1});
            EEGDisplayer.topoplotPSD(PSDClass2, frequencies, frequenciesToPlot, chanlocs16, 2, classLabels{2});
            EEGDisplayer.topoplotPSD(abs(PSDClass2 - PSDClass1), ...
                frequencies, frequenciesToPlot, chanlocs16, 3, 'Difference');
            drawnow();
        end

        function topoplotPSD(PSDs, frequencies, frequenciesToPlot, chanlocs64, rowIndex, titleForRow)
            for frequency = 1:length(frequenciesToPlot)
                subplot(3,length(frequenciesToPlot),frequency + (rowIndex -1)*length(frequenciesToPlot));
                indexToAverage = frequencies > frequenciesToPlot(frequency,1) & frequencies < frequenciesToPlot(frequency,2);
                plot_mytopoplot(mean(PSDs(:,indexToAverage),2), chanlocs64, 'conv', 'off', 'style', 'map', 'limits', [-3 3]);
                title([num2str(frequenciesToPlot(frequency,1)) '-' num2str(frequenciesToPlot(frequency, 2)) 'Hz']);
                if(frequency == 1)
                   xl = xlim;
                   h = text(xl(1)*1.2, 0, titleForRow, 'FontSize',16, 'HorizontalAlignment', 'center');
                   set(h,'Rotation',90);
                end
            end
        end
    end
end

