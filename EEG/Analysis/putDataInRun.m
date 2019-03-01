function eegrun = putDataInRun(eegrun, data)
    eegrun.mvt = data.gaMvt;
    eegrun.rest = data.gaRest;
    eegrun.spectMvt = data.gaSpectMvt;
    eegrun.spectRest = data.gaSpectRest;
end