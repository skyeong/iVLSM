function varargout = vlsm(varargin)
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

% Last Modified by GUIDE v2.5 09-Jun-2015 11:56:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @vlsm_OpeningFcn, ...
    'gui_OutputFcn',  @vlsm_OutputFcn, ...
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
function vlsm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vlsm (see VARARGIN)

% Choose default command line output for vlsm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
vlsm_defaults(handles);

% UIWAIT makes vlsm wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vlsm_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_subjlist_Callback(hObject, eventdata, handles)
global VLSM

% Hints: get(hObject,'String') returns contents of edit_subjlist as text
%        str2double(get(hObject,'String')) returns contents of edit_subjlist as a double

filepath = get(hObject,'String');
[~,~,xls] = xlsread(fullfile(PathName,FileName));
hdr = xls(1,:);
dat = xls(2:end,:);

VLSM.filepath = fullfile(PathName,FileName);
set(handles.edit_subjlist,'String',fullfile(PathName,FileName));



% --- Executes on button press in pushbutton_subjlist.
function pushbutton_subjlist_Callback(hObject, eventdata, handles)
global VLSM
[FileName, PathName] = uigetfile({'*.xls;*.xlsx','Excel files (*.xls,*.xlsx)'});
[~,~,xls] = xlsread(fullfile(PathName,FileName));
hdr = xls(1,:);
dat = xls(2:end,:);

for i=1:length(hdr),
    if strcmp(hdr{i},'subjname'),
        subjname = dat(:,i);
    elseif strcmp(hdr{i}, 'group'),
        group = cell2mat(dat(:,i));
    end
end
VLSM.nsubj = length(subjname);
VLSM.ngrp = length(unique(group));
VLSM.subjname = subjname;
VLSM.group = group;
VLSM.inputFile = fullfile(PathName,FileName);

text_nsubj = sprintf('Number of Subjects: %d', VLSM.nsubj);
text_ngrp = sprintf('Number of Groups: %d', VLSM.ngrp);

set(handles.edit_subjlist,'String',fullfile(PathName,FileName));
set(handles.text_nsubj,'String',text_nsubj);
set(handles.text_ngrp,'String',text_ngrp);



function edit_datapath_Callback(hObject, eventdata, handles)
global VLSM
VLSM.DATApath = DATApath;
set(handles.edit_datapath,'String',DATApath);


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
function popupmenu_modality_Callback(hObject, eventdata, handles)
global VLSM;

index_input_data = get(hObject,'Value');

if index_input_data == 2,
    % T1
    VLSM.modality = 'T1';
elseif index_input_data == 3,
    % EPI such as Diffusion Tensor Imaging
    VLSM.modality = 'EPI';
else
    VLSM.modality = '';
end


function pushbutton_normalization_Callback(hObject, eventdata, handles)
global VLSM;
doSeg = VLSM.doSeg;
if doSeg,
    vlsm_normalization(handles);
else,
    if ~isempty(VLSM.modality)
        vlsm_normalization(handles);
    else,
        errordlg('You should specify Imaging Modality');
    end
end


function checkbox_segment_Callback(hObject, eventdata, handles)
global VLSM;

doSeg = get(hObject,'Value');
VLSM.doSeg = doSeg;




%--------------------------------------------------------------------------
%  Parameters for Chi-Square Test
%--------------------------------------------------------------------------
function edit_pvalue_chi2_Callback(hObject, eventdata, handles)
global VLSM
pvalue = str2double(get(hObject,'String'));
VLSM.pvalue_chi2 = pvalue;


% --- Executes on button press in checkbox_FDR_chi2.
function checkbox_FDR_chi2_Callback(hObject, eventdata, handles)
global VLSM
val = get(hObject,'Value');
VLSM.FDR_chi2 = val;



%--------------------------------------------------------------------------
%  Parameters for VLSM Analysis
%--------------------------------------------------------------------------
function edit_pvalue_vlsm_Callback(hObject, eventdata, handles)
global VLSM
pvalue = str2double(get(hObject,'String'));
VLSM.pvalue_vlsm = pvalue;


function checkbox_FDR_vlsm_Callback(hObject, eventdata, handles)
global VLSM
val = get(hObject,'Value');
VLSM.FDR_vlsm = val;


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
function pushbutton_overlay_Callback(hObject, eventdata, handles)
set(handles.text_status,'String', 'Creating overlay image...'); pause(0.5);
vlsm_overlay(handles);



%--------------------------------------------------------------------------
%  Chi-Square Test Buttons
%--------------------------------------------------------------------------
function pushbutton_chi2test_Callback(hObject, eventdata, handles)
set(handles.text_status,'String', 'Performing chi2test between groups...'); pause(0.5);
vlsm_chi2tests(handles);


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
