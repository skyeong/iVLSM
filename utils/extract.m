function varargout = extract(varargin)
% EXTRACT MATLAB code for extract.fig
%      EXTRACT, by itself, creates a new EXTRACT or raises the existing
%      singleton*.
%
%      H = EXTRACT returns the handle to a new EXTRACT or the handle to
%      the existing singleton*.
%
%      EXTRACT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTRACT.M with the given input arguments.
%
%      EXTRACT('Property','Value',...) creates a new EXTRACT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before extract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to extract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help extract

% Last Modified by GUIDE v2.5 14-Oct-2016 08:10:52

% Begin initialization code - DO NOT EDIT

if nargin == 0  % LAUNCH GUI
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @extract_OpeningFcn, ...
        'gui_OutputFcn',  @extract_OutputFcn, ...
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
    
    % Generate a structure of handles to pass to callbacks, and store it.
    fig = openfig(mfilename,'reuse');
    handles = guihandles(fig);
    guidata(fig, handles);
    set(fig, 'Name','iVLSM Utility');
    
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
end



% End initialization code - DO NOT EDIT





% --- Executes just before extract is made visible.
function extract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to extract (see VARARGIN)

% Choose default command line output for extract
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes extract wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = extract_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton_lesionImgPath.
function pushbutton_lesionImgPath_Callback(hObject, eventdata, handles)
global UTIL
lesionImgPath = uigetdir();
UTIL.lesionImgPath = lesionImgPath;
set(handles.edit_lesionImgPath, 'String', lesionImgPath);


function edit_lesionImgPath_Callback(hObject, eventdata, handles)
global UTIL
UTIL.lesionImgPath = get(hObject,'String');


function edit_outpath_Callback(hObject, eventdata, handles)
global UTIL
UTIL.OUTpath = get(hObject,'String');


function edit_groupVar_Callback(hObject, eventdata, handles)
global UTIL
UTIL.groupVar = get(hObject,'String');


groupVar = get(hObject,'String');
hdr = UTIL.subjinfo.hdr;
dat = UTIL.subjinfo.dat;

group = [];
for i=1:length(hdr),
    if strcmpi(hdr{i}, groupVar),
        group = cell2mat(dat(:,i));
    end
end

UTIL.group = group;
UTIL.groupVar = groupVar;
UTIL.ngrp = length(unique(group));

if isempty(group),
    text_ngrp = sprintf('Number of groups: no group info');
else
    text_ngrp = sprintf('Number of groups: %d', UTIL.ngrp);
end

set(handles.text_ngrps,'String',text_ngrp);




function edit_subjlist_Callback(hObject, eventdata, handles)
global UTIL
UTIL.fp = get(hObject,'String');

[~,~,xls] = xlsread(UTIL.fp);
hdr = xls(1,:);
dat = xls(2:end,:);
UTIL.subjinfo.hdr = hdr;
UTIL.subjinfo.dat = dat;

for i=1:length(hdr),
    if strcmpi(hdr{i},'subjname'),
        subjList = dat(:,i);
    end
end
UTIL.subjList = subjList;



% --- Executes on button press in pushbutton_subjlist.
function pushbutton_subjlist_Callback(hObject, eventdata, handles)
global UTIL

[fn,fp] = uigetfile({'*.xls;*.xlsx','Excel Files (*.xls,*.xlsx)';'*.csv','Comma Seperated Value (*.csv)' },'Select file');
UTIL.fp = fullfile(fp, fn);
set(handles.edit_subjlist,'String',UTIL.fp);

[~,~,xls] = xlsread(UTIL.fp);
hdr = xls(1,:);
dat = xls(2:end,:);

for i=1:length(hdr),
    if strcmpi(hdr{i},'subjname'),
        subjList = dat(:,i);
    end
end

UTIL.subjinfo.hdr = hdr;
UTIL.subjinfo.dat = dat;
UTIL.subjList = subjList;
fprintf('Number of subjects in the list: %d\n',length(UTIL.subjList));



% --- Executes on button press in pushbutton_ROIs.
function pushbutton_ROIs_Callback(hObject, eventdata, handles)
global UTIL
[fns, maskImgPath] = uigetfile({'*.nii;*.img', 'All Imaging Files (*.img, *.nii)'},'Select a mask image file','MultiSelect', 'on');
UTIL.maskImgPath = maskImgPath;
ROIimgs = struct([]);
if iscell(fns)==0,
    ROIimgs{1} = fullfile(maskImgPath,fns);
    show_fns = fns;
    nROIimgs=1;
elseif length(fns)>1 && iscell(fns),
    for i=1:length(fns),
        ROIimgs{i} = fullfile(maskImgPath,fns{i});
        if i==1,
            show_fns = fns{i};
        else
            show_fns = [show_fns, ', ', fns{i}];
        end
    end
    nROIimgs = length(fns);
end

set(handles.text_ROI_Images,'String',show_fns);
UTIL.ROIimgs = ROIimgs;
UTIL.nROIimgs = nROIimgs;







% --- Executes on button press in pushbutton_OUTpath.
function pushbutton_OUTpath_Callback(hObject, eventdata, handles)
global UTIL
OUTpath = uigetdir();
UTIL.OUTpath = OUTpath;
set(handles.edit_outpath, 'String', OUTpath);





% --- Executes on button press in pushbutton_extract.
function pushbutton_extract_Callback(hObject, eventdata, handles)
global UTIL
set(handles.text_status,'String','Extracting ...'); pause(0.5);

% Subject's List
subjlist = UTIL.subjList;
nsubj = length(subjlist);

% Get User Setings
fn_ROIs   = UTIL.ROIimgs;
nROIimgs  = UTIL.nROIimgs;
maskImgPath = UTIL.maskImgPath;
lesionImgPath = UTIL.lesionImgPath;
OUTpath   = UTIL.OUTpath;
groupVar  = UTIL.groupVar;
group  = UTIL.group;
grplabel  = unique(UTIL.group);
ngrp = length(grplabel);

LesionPct = zeros(nsubj,nROIimgs);
for c=1:nsubj,
    subjname = subjlist{c};
    
    status_message = sprintf('[%03d/%03d] Extract from %s...',c,nsubj,subjname);
    set(handles.text_status,'String',status_message); pause(0.5);
    
    imgName = sprintf('^wl.*.%s.nii', subjname);
    fn_roi = spm_select('FPList',lesionImgPath,imgName);
    
    VOL = spm_vol(fn_roi);
    IMG = spm_read_vols(VOL);
    
    for r=1:nROIimgs,
        fn_ROI = fn_ROIs{r};
        vo_ROI = spm_vol(fn_ROI);
        ROI = spm_read_vols(vo_ROI);
        idroi = find(ROI>0);
        [vx, vy, vz] = ind2sub(vo_ROI.dim, idroi);
        ROIxyz = [vx, vy, vz, ones(size(vx))];
        Rxyz = vo_ROI.mat*ROIxyz';
        IMGxyz = pinv(VOL.mat)*Rxyz;
        
        zvals = spm_sample_vol(IMG, IMGxyz(1,:), IMGxyz(2,:), IMGxyz(3,:), 0);
        LesionPct(c,r) = 100*sum(zvals(isfinite(zvals)))/length(zvals);
    end
end

% Define output file name
meanVal = zeros(ngrp,nROIimgs);
serrVal = zeros(ngrp,nROIimgs);
for g=1:ngrp,
    idgrp = find(group==grplabel(g));
    meanVal(g,:) = mean(LesionPct(idgrp,:));
    serrVal(g,:) = std(LesionPct(idgrp,:))/sqrt(length(idgrp));
end


% Plot results
%--------------------------------------------------------------------------
for i=1:nROIimgs,
    figure;
    bar(grplabel,meanVal(:,i),'FaceColor',[0.7 0.7 0.7],'barwidth',.9); hold on;
    for g=1:ngrp,
        ylower  = meanVal(g,:)-serrVal(g,:);
        yhigher = meanVal(g,:)+serrVal(g,:);
        line([grplabel(g), grplabel(g)],[ylower, yhigher],'LineWidth',3,'Color','r');
    end
    xlabel(groupVar{1},'FontSize',12);
    ylabel('Percentage of lesion within a ROI','FontSize',12);
end


% Writing Resulting Values
%--------------------------------------------------------------------------
[p,f,e] = fileparts(fn_ROIs{1});
set(handles.text_status,'String','Writing results.');
fn_out = fullfile(OUTpath,sprintf('Lesion_size_within_ROI_%s.csv',groupVar{1}));
fid = fopen(fn_out,'w+');


% Writing Resulting Values
fprintf(fid,'subjname,');
for i=1:nROIimgs,
    fn_ROI = fn_ROIs{i};
    [p,f,e] = fileparts(fn_ROI);
    if i==nROIimgs,
        fprintf(fid,'%s\n',f);
    else
        fprintf(fid,'%s,',f);
    end
end


fmt = repmat('%.2f,',1,nROIimgs);
fmt(end) = ''; fmt = ['%s,' fmt, '\n'];
for c=1:nsubj,
    subjname = subjlist{c};
    fprintf(fid, fmt, subjname, LesionPct(c,:));
end
fclose(fid);
set(handles.text_status,'String','Done.');
