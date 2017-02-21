function vlsm_overlay(handles)
global VLSM


% Check SPM version
try
    spmver = spm('ver');
catch
    spmver = '';
end

if ~strcmpi(spmver,'SPM12'),
    disp('Addpath SPM12 toolbox directory');
    return
end


spm('Defaults', 'fMRI');


% Change 'Run' button color
set(handles.pushbutton_overlay,'ForegroundColor',[1 1 1]);
set(handles.pushbutton_overlay,'BackgroundColor',[11 132 199]./256);
pause(0.2);



% Get Parameters from VLSM
DATApath = VLSM.DATApath;
subjlist = VLSM.subjname;
nsubj = length(subjlist);

ROIfolder = VLSM.ROIfolder;
ROIprefix = VLSM.ROIprefix;

groupVar = VLSM.groupVar;
group    = VLSM.group;
ngrp     = VLSM.ngrp;
idg      = unique(group);


% Output Path Setup
OUTpath = fullfile(DATApath,'overlay',groupVar); mkdir(OUTpath);

% Load reference
fn_tmp = sprintf('w%s%s.nii',ROIprefix,subjlist{1});
fn_roi = fullfile(DATApath, ROIfolder, fn_tmp);
vref = spm_vol(fn_roi);
idbrainmask = fmri_load_maskindex(vref);



% Overlay Imaging data
if ngrp>1,
    IMG = zeros([ngrp, prod(vref.dim)]);
else
    IMG = zeros([1, prod(vref.dim)]);
end

for c=1:nsubj,
    fn_tmp = sprintf('w%s%s.nii',ROIprefix, subjlist{c});
    fn_roi = fullfile(DATApath, ROIfolder, fn_tmp);
    vo = spm_vol(fn_roi);
    I = spm_read_vols(vo);
    %idx = find(I>0);
    idroi = find(I>0);
    idx = intersect(idbrainmask, idroi);
    
    if ngrp>1,
        IMG(group(c),idx) = IMG(group(c),idx) + 1;
    else
        IMG(1,idx) = IMG(1,idx) + 1;
    end
end

% Write the resulting overlay image
if ngrp>1,
    for i=1:ngrp,
        Iout = zeros(vref.dim);
        idsubj = find(group==idg(i));
        fn = sprintf('overlay_grp%d_nsubj%d.nii',idg(i),length(idsubj));
        v = vref;
        v.dt = [16 0];
        v.fname = fullfile(OUTpath, fn);
        Iout = reshape(IMG(i,:),vref.dim);
        spm_write_vol(v, Iout);
    end
end

fn = sprintf('overlay_all_nsubj%d.nii',nsubj);
v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, fn);
if ngrp>1,  Iout = reshape(sum(IMG), vref.dim);
else,       Iout = reshape(IMG,vref.dim); end
spm_write_vol(v, Iout);



% Change 'Run' button color to the original 
set(handles.pushbutton_overlay,'ForegroundColor',[0 0 0]);
set(handles.pushbutton_overlay,'BackgroundColor',[248 248 248]./256);

pause(0.5);
text_status = sprintf('overlay image was created.');
set(handles.text_status,'String',text_status);
