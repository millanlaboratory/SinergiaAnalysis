classdef CARFilter < SpatialFilter & handle
    
    methods
        function obj = CARFilter(nbChannels)
            obj@SpatialFilter(nbChannels);
            obj.filterMatrix = ones(nbChannels) - diag(diag(ones(nbChannels)));
            obj.filterMatrix = diag(diag(ones(nbChannels)))-obj.filterMatrix/nbChannels;
        end
    end
end

