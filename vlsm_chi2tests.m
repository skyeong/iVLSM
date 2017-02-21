function vlsm_chi2tests(handles)
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


% Get Parameters from VLSM
DATApath = VLSM.DATApath;
subjlist = VLSM.subjname;
nsubj = length(subjlist);

ROIfolder = VLSM.ROIfolder;
ROIprefix = VLSM.ROIprefix;
groupVar  = VLSM.groupVar;
ngrp      = VLSM.ngrp;

if ngrp<2,
    % Print Status on chi2test window
    pause(0.5);
    text_status = sprintf('Error: No. of groups >= 2.');
    set(handles.text_status,'String',text_status);
    return
end


% Change 'Run' button color
set(handles.pushbutton_chi2test,'ForegroundColor',[1 1 1]);
set(handles.pushbutton_chi2test,'BackgroundColor',[11 132 199]./256);
pause(0.2);


% Output Path Setup
OUTpath = fullfile(DATApath,'chi2test',groupVar); mkdir(OUTpath);


% Get Image information
fn_tmp = sprintf('w%s%s.nii',ROIprefix, subjlist{1});
fn_roi = fullfile(DATApath, ROIfolder, fn_tmp);
vref = spm_vol(fn_roi);
idbrainmask = fmri_load_maskindex(vref);

% Find Valid Voxels
IMG = zeros(vref.dim);
for c=1:nsubj,
    fn_tmp = sprintf('w%s%s.nii',ROIprefix, subjlist{c});
    fn_roi = fullfile(DATApath, ROIfolder, fn_tmp);
    vo = spm_vol(fn_roi);
    I = spm_read_vols(vo);
    idroi = find(I>0);
    idx = intersect(idroi,idbrainmask);
    IMG(idx) = IMG(idx) + 1;
end


% Collect Data from All Subjects
idvox = find(IMG>0); clear IMG;
nvox = length(idvox);
data = zeros(nsubj,nvox);
for c=1:nsubj,
    fn_tmp = sprintf('w%s%s.nii',ROIprefix, subjlist{c});
    fn_roi = fullfile(DATApath, ROIfolder, fn_tmp);
    vo = spm_vol(fn_roi);
    I = spm_read_vols(vo);
    data(c,:) = I(idvox);
end


% Extract Groups
group = VLSM.group;
idg = unique(group);
grp = struct([]);
for g=1:length(idg),
    grp(g).idx = find(group==g);
end

Pval = zeros(nvox,1);
Chi2 = zeros(nvox,1);
parfor i=1:nvox,
    dat = data(:,i);
    [tbl,chi2,p] = crosstab(group, dat);
    % dat1 = dat(grp(1).idx);
    % dat2 = dat(grp(2).idx);
    % [p, chi2] = chi2tests(dat1, dat2);
    Pval(i) = p;
    Chi2(i) = chi2;
end


%--------------------------------------------------------------------------
% Write the resulting group comparison
%--------------------------------------------------------------------------

% Get significant voxels
ids = find(Pval<1);

% Write Chi2 image
IMG = zeros(vref.dim);
IMG(idvox(ids)) = Chi2(ids);

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'crosstab_chi2.nii');
spm_write_vol(v, IMG);

% Write -log10(Puncorr) image
IMG = zeros(vref.dim);
IMG(idvox(ids)) = -log10(Pval(ids));

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'crosstab_log10_P_uncorr.nii');
spm_write_vol(v, IMG);


% Write -log10(Pfdr) image
[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(Pval);
IMG = zeros(vref.dim);
IMG(idvox(ids)) = -log10(adj_p(ids));

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'crosstab_log10_P_fdr.nii');
spm_write_vol(v, IMG);



% Change 'Run' button color to the original
set(handles.pushbutton_chi2test,'ForegroundColor',[0 0 0]);
set(handles.pushbutton_chi2test,'BackgroundColor',[248 248 248]./256);


% Print Status on chi2test window
pause(0.5);
text_status = sprintf('images of chi2test result were created.');
set(handles.text_status,'String',text_status);
