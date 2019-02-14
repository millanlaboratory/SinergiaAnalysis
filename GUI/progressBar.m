classdef progressBar
    %PROGRESSBAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ax1
    end
    
    methods
        function obj = progressBar(parent)
            %PROGRESSBAR Construct an instance of this class
            %   Detailed explanation goes here
            obj.ax1=axes(parent);
            set(obj.ax1,'Xtick',[],'Ytick',[],'Xlim',[0 1], 'Position', [0,0,1,1]);
            box on;
        end
        
        function update(obj,percentage)
            axes(obj.ax1)
            cla
            rectangle('Position',[0,0,percentage,1],'FaceColor',[0.1 0.78 0.1]);
            drawnow();
            %text(482,10,[num2str(round(100*percentage)),'%']);
        end
    end
end

