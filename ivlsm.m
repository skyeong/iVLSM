function varargout = ivlsm(varargin)
% VLSM MATLAB code for vlsm.fig
%      VLSM, by itself, creates a new VLSM or raises the existing
%      singleton*.
%
%      H = VLSM returns the handle to a new VLSM or the handle to
%      the existing singleton*.
%
%      VLSM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VLSM.M with the given input arguments.
%
%      VLSM('Property','Value',...) creates a new VLSM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vlsm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vlsm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vlsm

% Last Modified by GUIDE v2.5 16-Mar-2017 13:39:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ivlsm_OpeningFcn, ...
    'gui_OutputFcn',  @ivlsm_OutputFcn, ...
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


% --- Executes just before vlsm is made visible.
function ivlsm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vlsm (see VARARGIN)

% Choose default command line output for vlsm
handles.output = hObject;

% Update handles structure
warning('off','all');
guidata(hObject, handles);
vlsm_defaults(handles);

% Addpath toolbox
global VLSM
PathName = fileparts(which('ivlsm'));
VLSM.iVLSMpath = PathName;
addpath(genpath(PathName));

% UIWAIT makes vlsm wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ivlsm_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_subjlist_Callback(hObject, eventdata, handles)
global VLSM
filepath = get(hObject,'String');
VLSM.filepath = filepath;
set(handles.edit_subjlist,'String',fullfile(PathName,FileName));



% --- Executes on button press in pushbutton_subjlist.
function pushbutton_subjlist_Callback(hObject, eventdata, handles)
global VLSM
[FileName, PathName] = uigetfile({'*.xls;*.xlsx','Excel files (*.xls,*.xlsx)'});
[~,~,xls] = xlsread(fullfile(PathName,FileName));
hdr = xls(1,:);
dat = xls(2:end,:);

group=[];
for i=1:length(hdr),
    if strcmpi(hdr{i},'subjname'),
        subjname = dat(:,i);
    elseif strcmpi(hdr{i}, VLSM.groupVar),
        group = cell2mat(dat(:,i));
    end
end
VLSM.subjinfo.hdr = hdr;
VLSM.subjinfo.dat = dat;
VLSM.nsubj = length(subjname);
VLSM.ngrp = length(unique(group));
VLSM.subjname = subjname;
VLSM.group = group;
VLSM.inputFile = fullfile(PathName,FileName);

text_nsubj = sprintf('Number of Subjects: %d', VLSM.nsubj);
if isempty(group),
    text_ngrp = sprintf('Number of Groups: no group info');
else
    text_ngrp = sprintf('Number of Groups: %d', VLSM.ngrp);
end

set(handles.edit_subjlist,'String',fullfile(PathName,FileName));
set(handles.text_nsubj,'String',text_nsubj);
set(handles.text_ngrp,'String',text_ngrp);



function edit_datapath_Callback(hObject, eventdata, handles)
global VLSM
DATApath = get(hObject,'String');
VLSM.DATApath = DATApath{1};
set(handles.edit_datapath,'String',VLSM.DATApath);


% --- Executes on button press in pushbutton_datapath.
function pushbutton_datapath_Callback(hObject, eventdata, handles)
global VLSM
DATApath = uigetdir;
VLSM.DATApath = DATApath;
set(handles.edit_datapath,'String',DATApath);



%--------------------------------------------------------------------------
%  Variables for Step2: T1 (Structural Image)
%--------------------------------------------------------------------------
function edit_T1prefix_Callback(hObject, eventdata, handles)
global VLSM
VLSM.T1prefix = get(hObject,'String');


function edit_T1folder_Callback(hObject, eventdata, handles)
global VLSM
VLSM.T1folder = get(hObject,'String');


%--------------------------------------------------------------------------
%  Variables for Step3: ROI (Lesion Image)
%--------------------------------------------------------------------------
function edit_ROIprefix_Callback(hObject, eventdata, handles)
global VLSM
VLSM.ROIprefix = get(hObject,'String');


function edit_ROIfolder_Callback(hObject, eventdata, handles)
global VLSM
VLSM.ROIfolder = get(hObject,'String');




%--------------------------------------------------------------------------
%  Parameters for Normalization
%--------------------------------------------------------------------------
function checkbox_segment_Callback(hObject, eventdata, handles)
global VLSM;
doSeg = get(hObject,'Value');
VLSM.doSeg = doSeg;

function pushbutton_normalization_Callback(hObject, eventdata, handles)
vlsm_normalization(handles);





%--------------------------------------------------------------------------
%  Parameters for Overlapping and Crosstab analysis
%--------------------------------------------------------------------------
function popupmenu_groupStat_Callback(hObject, eventdata, handles)
global VLSM;

index_input_data = get(hObject,'Value');

if index_input_data == 1,
    % Overlap map
    VLSM.statMethods = 'overlap';
    disp('Analysis methods: Create overlay map');
elseif index_input_data == 2,
    % Pearson's Chi-squared test
    VLSM.statMethods = 'chi2test';
    disp('Analysis methods: Pearson Chi2 Test');
else
    % Logistic regression (covariates are available)
    VLSM.statMethods = 'logistic';
    disp('Analysis methods: Logistic Regression');
end



function edit_groupVar_Callback(hObject, eventdata, handles)
global VLSM;

groupVar = get(hObject,'String');

hdr = VLSM.subjinfo.hdr;
dat = VLSM.subjinfo.dat;

group = [];
for i=1:length(hdr),
    if strcmpi(hdr{i}, groupVar),
        group = cell2mat(dat(:,i));
    end
end

VLSM.group = group;
VLSM.groupVar = groupVar;
VLSM.ngrp = length(unique(group));

if isempty(group),
    text_ngrp = sprintf('Number of Groups: no group info');
else
    text_ngrp = sprintf('Number of Groups: %d', VLSM.ngrp);
end

set(handles.text_ngrp,'String',text_ngrp);


function edit_covariates_Callback(hObject, eventdata, handles)
global VLSM;
% hObject    handle to edit_covariates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(VLSM.inputFile),
   disp('Select Subject List in Step1 ...'); 
   return
end

covariateNames = strsplit(get(hObject,'String'),'\s*,\s*',...
    'DelimiterType','RegularExpression');
nsubj = VLSM.nsubj;
hdr = VLSM.subjinfo.hdr;
dat = VLSM.subjinfo.dat;

nCovariates = 0;
if isempty(covariateNames{1}),
    covariateVars = [];
    covariateNames = '';
else
    covariateVars = zeros(nsubj,0);
    for i=1:length(covariateNames),
        for j=1:length(hdr),
            if strcmpi(covariateNames{i},hdr{j}),
                covariateVars(:,i) = cell2mat(dat(:,j));
                nCovariates = nCovariates+1;
            end
        end
    end
end

VLSM.nCovariates = nCovariates;
VLSM.covariate.values = covariateVars;
if nCovariates>1,
    VLSM.covariate.names = strjoin(covariateNames,'_');
else
    VLSM.covariate.names = covariateNames;
end






%--------------------------------------------------------------------------
%  Parameters for VLSM Analysis
%--------------------------------------------------------------------------
function edit_medvars_Callback(hObject, eventdata, handles)
global VLSM
vars = get(hObject,'String');
medvars = splitstrings(vars,',');
VLSM.medvars = medvars;


function edit_nMinSubj_Callback(hObject, eventdata, handles)
global VLSM
nMinSubj = str2double(get(hObject,'String'));
VLSM.nMinSubj = nMinSubj;


function popupmenu_StatMethods_Callback(hObject, eventdata, handles)
global VLSM;

index_input_data = get(hObject,'Value');

if index_input_data == 1,
    % Mann-whitey U-test
    VLSM.statMethods = 'mw';
elseif index_input_data == 2,
    % independent t-test
    VLSM.statMethods = 'ttest';
else
    VLSM.statMethods = '';
end




%--------------------------------------------------------------------------
%  Overlay Buttons
%--------------------------------------------------------------------------
function pushbutton_runGroup_Callback(hObject, eventdata, handles)
global VLSM

if strcmpi(VLSM.statMethods,'overlap'),
    set(handles.text_status,'String', 'Creating overlay map...'); pause(0.5);
    vlsm_overlay(handles);
elseif strcmpi(VLSM.statMethods,'chi2test'),
    set(handles.text_status,'String', 'Performing Pearson Chi2 Test...'); pause(0.5);
    vlsm_chi2tests(handles);
elseif strcmpi(VLSM.statMethods,'logistic'),
    set(handles.text_status,'String', 'Performing logistic regression...'); pause(0.5);
    vlsm_logistic(handles);
else
    disp('Analysis methods - selection error');
end



%--------------------------------------------------------------------------
%  Correlation Analysis Buttons
%--------------------------------------------------------------------------
function pushbutton_vlsm_Callback(hObject, eventdata, handles)
global VLSM;
if isempty(VLSM.statMethods),
    errordlg('Specify Statistical Methods', 'Run Error');
    return
end
set(handles.text_status,'String', 'Performing lesion-symptom mapping...'); pause(0.5);
vlsm_mapping(handles);


% --- Executes on button press in pushbutton_extractROIvalue.
function pushbutton_extractROIvalue_Callback(hObject, eventdata, handles)
extract


% --- Executes on button press in pushbutton_createROIs.
function pushbutton_createROIs_Callback(hObject, eventdata, handles)
create_ROI_mask


% --- Executes on button press in pushbutton_filpImages.
function pushbutton_filpImages_Callback(hObject, eventdata, handles)
imageFlip


% --- Executes on button press in pushbutton_thresholding.
function pushbutton_thresholding_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_thresholding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
