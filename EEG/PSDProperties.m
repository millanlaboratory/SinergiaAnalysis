classdef PSDProperties < handle
    properties
        windowSize = 1 %s
        overlap = 0.5 %s
        frequenciesToStudy
        epochFrequency = 16 %Hz
    end
    methods
        function obj = PSDProperties(windowSize, overlap, frequenciesToStudy, epochFrequency)
            obj.windowSize = windowSize;
            obj.overlap = overlap;
            obj.frequenciesToStudy = frequenciesToStudy;
            obj.epochFrequency = epochFrequency;
        end
    end
    
end