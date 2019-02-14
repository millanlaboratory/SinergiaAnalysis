function varargout = DataSelection(varargin)
% DATASELECTION MATLAB code for DataSelection.fig
%      DATASELECTION, by itself, creates a new DATASELECTION or raises the existing
%      singleton*.
%
%      H = DATASELECTION returns the handle to a new DATASELECTION or the handle to
%      the existing singleton*.
%
%      DATASELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATASELECTION.M with the given input arguments.
%
%      DATASELECTION('Property','Value',...) creates a new DATASELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataSelection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataSelection

% Last Modified by GUIDE v2.5 13-Feb-2019 15:02:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @DataSelection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DataSelection is made visible.
function DataSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataSelection (see VARARGIN)

% Choose default command line output for DataSelection
handles.output = hObject;


handles.shouldStop = false;
set(handles.analyze, 'BackgroundColor', [0.94 0.94 0.94]);
set(handles.cancel, 'BackgroundColor', [0.94 0.94 0.94]);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes DataSelection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function subjectFolderTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to subjectFolderTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of subjectFolderTextBox as text
%        str2double(get(hObject,'String')) returns contents of subjectFolderTextBox as a double

% --- Executes during object creation, after setting all properties.
function subjectFolderTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectFolderTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in subjectsList.
function subjectsList_Callback(hObject, eventdata, handles)
% hObject    handle to subjectsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns subjectsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subjectsList


% --- Executes during object creation, after setting all properties.
function subjectsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sessionsList.
function sessionsList_Callback(hObject, eventdata, handles)
% hObject    handle to sessionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sessionsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sessionsList


% --- Executes during object creation, after setting all properties.
function sessionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sessionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in validateSessions.
function validateSessions_Callback(hObject, eventdata, handles)
% hObject    handle to validateSessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.runsList, 'Visible', 'on');
set(handles.runsLabel, 'Visible', 'on');
set(handles.selectAllRuns, 'Visible', 'on');
set(handles.validateRuns, 'Visible', 'on')
runNames = {};
subjects = get(handles.subjectsList, 'String');
subjects = subjects(get(handles.subjectsList, 'Value'));
folder = get(handles.subjectFolderTextBox,'String');
for indexSubject = 1:length(subjects)
    sessions = get(handles.sessionsList, 'String');
    sessions = sessions(get(handles.sessionsList, 'Value'));
    for indexSession = 1:length(sessions)
        fileNames = dir([folder '/' subjects{indexSubject} '/' sessions{indexSession}]);
        for indexRun = 1:length(fileNames)
            if ~fileNames(indexRun).isdir && contains(fileNames(indexRun).name, '.gdf')
                runNames{end+1} = fileNames(indexRun).name;
            end
        end
    end
end
set(handles.runsList,'String',unique(runNames))
set(handles.runsList,'Value',[])


% --- Executes on selection change in runsList.
function runsList_Callback(hObject, eventdata, handles)
% hObject    handle to runsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns runsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from runsList


% --- Executes during object creation, after setting all properties.
function runsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectAllSessions.
function selectAllSessions_Callback(hObject, eventdata, handles)
% hObject    handle to selectAllSessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sessions = get(handles.sessionsList,'String');
set(handles.sessionsList,'Value',1:length(sessions))

% --- Executes on button press in validateSubjects.
function validateSubjects_Callback(hObject, eventdata, handles)
% hObject    handle to validateSubjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.sessionsList, 'Visible', 'on');
set(handles.sessionsLabel, 'Visible', 'on');
set(handles.selectAllSessions, 'Visible', 'on');
set(handles.validateSessions, 'Visible', 'on');
set(handles.sessionsList, 'Visible', 'on');
setUniqueSessionList(handles);
selectMovementSessions(hObject, eventdata, handles);
if strcmp(get(handles.runsList, 'Visible'), 'on')
    validateSessions_Callback(hObject, eventdata, handles)
end

function setUniqueSessionList(handles)
    dirNames = {};
    subjects = get(handles.subjectsList, 'String');
    subjects = subjects(get(handles.subjectsList, 'Value'));
    folder = get(handles.subjectFolderTextBox,'String');
    for indexSubject = 1:length(subjects)
        fileNames = dir([folder '/' subjects{indexSubject}]);
        for indexSession = 1:length(fileNames)
            if fileNames(indexSession).isdir && isSessionFolder(fileNames(indexSession).name)
                dirNames{end+1} = fileNames(indexSession).name;
            end
        end
    end
    set(handles.sessionsList,'String',unique(dirNames))
    set(handles.sessionsList,'Value', 1:length(unique(dirNames)))


% --- Executes on button press in selectAllSubjects.
function selectAllSubjects_Callback(hObject, eventdata, handles)
% hObject    handle to selectAllSubjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subjects = get(handles.subjectsList,'String');
set(handles.subjectsList,'Value',1:length(subjects))

% --- Executes on button press in validateFolder.
function validateFolder_Callback(hObject, eventdata, handles)
% hObject    handle to validateFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileNames = dir(get(handles.subjectFolderTextBox,'String'));
dirNames = {};
for index = 1:length(fileNames)
    if fileNames(index).isdir && ~strcmp(fileNames(index).name, '.') && ~strcmp(fileNames(index).name, '..')
        dirNames{end+1} = fileNames(index).name;
    end
end
set(handles.subjectsList, 'Visible', 'on');
set(handles.subjectsLabel, 'Visible', 'on');
set(handles.selectAllSubjects, 'Visible', 'on');
set(handles.validateSubjects, 'Visible', 'on');
set(handles.subjectsList, 'Visible', 'on');
set(handles.subjectsList,'String',dirNames)


% --- Executes on button press in selectFoldeFlex
function selectFolder_Callback(hObject, eventdata, handles)
% hObject    handle to selectFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dname = uigetdir(get(handles.subjectFolderTextBox,'String'));
if dname ~= 0
    set(handles.subjectFolderTextBox,'String', dname);
end


% --- Executes on button press in analyze.
function analyze_Callback(hObject, eventdata, handles)
% hObject    handle to analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set( findall(handles.selection, '-property', 'Enable'), 'Enable', 'off')
set( findall(handles.analysisGroup, '-property', 'Enable'), 'Enable', 'off')
set(handles.analyze, 'BackgroundColor', [0.94 0.94 0.94]);
set(handles.analyze, 'Enable', 'off');
set(handles.cancel, 'BackgroundColor', [1.0 0.0 0.0]);
set(handles.cancel, 'Enable', 'on');
Analyze(hObject, handles)
set( findall(handles.selection, '-property', 'Enable'), 'Enable', 'on')
set( findall(handles.analysisGroup, '-property', 'Enable'), 'Enable', 'on')
set(handles.cancel, 'BackgroundColor', [0.94 0.94 0.94]);
set(handles.cancel, 'Enable', 'off');
set(handles.analyze, 'BackgroundColor', [0.1 0.78 0.1]);
set(handles.analyze, 'Enable', 'on');




    

    
% --- Executes on button press in perSubject.
function perSubject_Callback(hObject, eventdata, handles)
% hObject    handle to perSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enableAnalyzeButton(handles);
% Hint: get(hObject,'Value') returns toggle state of perSubject


% --- Executes on button press in allSubjects.
function allSubjects_Callback(hObject, eventdata, handles)
% hObject    handle to allSubjects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enableAnalyzeButton(handles);
% Hint: get(hObject,'Value') returns toggle state of allSubjects


% --- Executes on button press in perSession.
function perSession_Callback(hObject, eventdata, handles)
% hObject    handle to perSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enableAnalyzeButton(handles);
% Hint: get(hObject,'Value') returns toggle state of perSession

function enableAnalyzeButton(handles)
    if get(handles.perSession, 'Value') == 1 || get(handles.perRun, 'Value') == 1 || ...
            get(handles.perSubject, 'Value') == 1 || get(handles.allSubjects, 'Value') == 1
        set(handles.analyze, 'BackgroundColor', [0.1 0.78 0.1]);
        set(handles.analyze, 'Enable', 'on');
    else
        set(handles.analyze, 'BackgroundColor', [0.94 0.94 0.94]);
        set(handles.analyze, 'Enable', 'off');
    end
    

% --- Executes on button press in flexion.
function flexion_Callback(hObject, eventdata, handles)
% hObject    handle to flexion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flexion
selectMovementSessions(hObject, eventdata, handles)
validateSessions_Callback(hObject, eventdata, handles);

% --- Executes on button press in extension.
function extension_Callback(hObject, eventdata, handles)
% hObject    handle to extension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extension
selectMovementSessions(hObject, eventdata, handles)
validateSessions_Callback(hObject, eventdata, handles);

function selectMovementSessions(hObject, eventdata, handles)
    selectFlexion = get(handles.flexion, 'Value') == 1;
    selectExtension = get(handles.extension, 'Value') == 1;
    setUniqueSessionList(handles);
    if selectFlexion || selectExtension
        sessions = get(handles.sessionsList,'String');
        sessionsValue = get(handles.sessionsList,'value');
        newSessions = {};
        newSessionsValues = [];
        for indexSession = 1:length(sessions)
            if (contains(sessions{indexSession}, 'flex') && selectFlexion) || ...
                    (contains(sessions{indexSession}, 'ext') && selectExtension)
                newSessions{end+1} = sessions{indexSession};
                if any(sessionsValue == indexSession)
                    newSessionsValues(end+1) = length(newSessions);
                end
            end
        end
        set(handles.sessionsList,'String',unique(newSessions));
        set(handles.sessionsList,'Value', newSessionsValues);
    end
    

% --- Executes on button press in topoplot.
function topoplot_Callback(hObject, eventdata, handles)
% hObject    handle to topoplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of topoplot


% --- Executes on button press in spectrogram.
function spectrogram_Callback(hObject, eventdata, handles)
% hObject    handle to spectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectrogram


% --- Executes on button press in discriminancyMap.
function discriminancyMap_Callback(hObject, eventdata, handles)
% hObject    handle to discriminancyMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of discriminancyMap


% --- Executes on button press in selectAllRuns.
function selectAllRuns_Callback(hObject, eventdata, handles)
% hObject    handle to selectAllRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
runs = get(handles.runsList,'String');
set(handles.runsList,'Value',1:length(runs))


% --- Executes on button press in validateRuns.
function validateRuns_Callback(hObject, eventdata, handles)
% hObject    handle to validateRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.analysisGroup, 'Visible', 'on')


% --- Executes on button press in perRun.
function perRun_Callback(hObject, eventdata, handles)
% hObject    handle to perRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enableAnalyzeButton(handles);
% Hint: get(hObject,'Value') returns toggle state of perRun



function analysisFolder_Callback(hObject, eventdata, handles)
% hObject    handle to analysisFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of analysisFolder as text
%        str2double(get(hObject,'String')) returns contents of analysisFolder as a double


% --- Executes during object creation, after setting all properties.
function analysisFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analysisFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectAnalysisFolder.
function selectAnalysisFolder_Callback(hObject, eventdata, handles)
% hObject    handle to selectAnalysisFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dname = uigetdir(get(handles.analysisFolder,'String'));
if dname ~= 0
    set(handles.analysisFolder,'String', dname);
end

% --- Executes on button press in recomputeAnalysis.
function recomputeAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to recomputeAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of recomputeAnalysis


% --- Executes on button press in saveAnalysis.
function saveAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to saveAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveAnalysis


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.shouldStop = true;
guidata(hObject, handles);
disp('cancelling ')
