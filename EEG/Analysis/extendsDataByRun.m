function data = extendsDataByRun(data, run)
    data.gaMvt(:,end+1:end+size(run.mvt,2),:) = run.mvt;
    data.gaRest(:,end+1:end+size(run.rest,2),:) = run.rest;
    if(size(run.spectMvt,4) ~= size(data.gaSpectMvt,4))
        sizeDifference = size(data.gaSpectMvt,4) - size(run.spectMvt,4);
        if(sizeDifference > 0)
            run.spectMvt(:,:,:,end+1:end+abs(sizeDifference)) = nan(size(run.spectMvt,1), size(run.spectMvt,2), size(run.spectMvt,3), abs(sizeDifference));
            run.spectRest(:,:,:,end+1:end+abs(sizeDifference)) = nan(size(run.spectRest,1), size(run.spectRest,2), size(run.spectRest,3), abs(sizeDifference));
        else
            data.gaSpectMvt(:,:,:,end+1:end+abs(sizeDifference)) = nan(size(data.gaSpectMvt,1), size(data.gaSpectMvt,2), size(data.gaSpectMvt,3), abs(sizeDifference));
            data.gaSpectRest(:,:,:,end+1:end+abs(sizeDifference)) = nan(size(data.gaSpectRest,1), size(data.gaSpectRest,2), size(data.gaSpectRest,3), abs(sizeDifference));
        end
    end
    data.gaSpectMvt(:,end+1:end+size(run.spectMvt,2),:,:) = run.spectMvt;
    data.gaSpectRest(:,end+1:end+size(run.spectRest,2),:,:) = run.spectRest;
end