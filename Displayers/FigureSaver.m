classdef FigureSaver < handle
    properties
        shouldSave
        folder
        formats
        folderExtension
        counter
    end
    
    methods
        function obj = FigureSaver(shouldSave, folder, formats)
            obj.shouldSave = shouldSave;
            obj.folder = folder;
            obj.formats = formats;
            obj.counter = 0;
        end
        
        function saveExplicitFigure(obj, currentFigure, filename)
            if obj.shouldSave
                fullpath = [obj.folder '/' obj.folderExtension];
                if ~exist(fullpath, 'dir')
                    mkdir(fullpath);
                end
                if obj.counter > 0
                    filename = [filename num2str(obj.counter)];
                end
                for indexFormat = 1:length(obj.formats)
                    if strcmp(obj.formats{indexFormat}, 'fig')
                        savefig(currentFigure, [fullpath '/' filename '.fig'], 'compact');
                    elseif strcmp(obj.formats{indexFormat}, 'pdf')
                        set(currentFigure,'PaperOrientation','landscape')
                        print([fullpath '/' filename '.pdf'],  '-dpdf')
                    elseif strcmp(obj.formats{indexFormat}, 'png')
                        print([fullpath '/' filename '.png'],  '-dpng')
                    end
                end
            end
        end
        
        function saveCurrentFigure(obj, filename)
            fig = gcf;
            obj.saveExplicitFigure(fig, filename);
        end
    end
end

