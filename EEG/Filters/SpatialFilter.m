classdef SpatialFilter < handle
    
    properties
        filterMatrix
        nbChannels
    end
    
    methods
        function obj = SpatialFilter(nbChannels)
            obj.nbChannels = nbChannels;
        end
        
        function filteredData = applyFilter(obj, data)
            filteredData = data * obj.filterMatrix;
        end
    end
end

