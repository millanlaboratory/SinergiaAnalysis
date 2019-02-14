classdef EEGDisplayer
    %EEGDISPLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        %% Discriminancy map
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

        function topoplotPSD(PSDs, frequencies, frequenciesToPlot, chanlocs16, rowIndex, titleForRow)
            for frequency = 1:length(frequenciesToPlot)
                subplot(3,length(frequenciesToPlot),frequency + (rowIndex -1)*length(frequenciesToPlot));
                indexToAverage = frequencies > frequenciesToPlot(frequency,1) & frequencies < frequenciesToPlot(frequency,2);
                plot_mytopoplot(mean(PSDs(:,indexToAverage),2), chanlocs16, 'conv', 'off', 'style', 'map', 'limits', [-3 3]);
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

