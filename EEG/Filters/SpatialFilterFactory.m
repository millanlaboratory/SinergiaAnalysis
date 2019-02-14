classdef SpatialFilterFactory < handle
    methods(Static)
        function filter = createSpatialFilter(filterType, nbChannels)
            if strcmp(filterType, 'CAR')
                filter = CARFilter(nbChannels);
            elseif strcmp(filterType, 'Laplacian')
                filter = LaplacianFilter(nbChannels);
            else
                error(['Filter type ' filterType ' unknown.']);
            end
        end
    end
end

