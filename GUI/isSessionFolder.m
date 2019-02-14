function isSession = isSessionFolder(fileName)
    forbiddenNames = {'.', '..','eegc3','resources', 'test'};
    isSession = true;
    for index = 1:length(forbiddenNames)
        if strcmp(fileName, forbiddenNames{index})
            isSession = false;
        end
    end
end