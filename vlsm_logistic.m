function vlsm_logistic(handles)
global VLSM


% Check SPM version
try
    spmver = spm('ver');
catch
    spmver = '';
end

if ~strcmpi(spmver,'SPM12'),
    text_status = sprintf('Error: Setpath SPM12 directory1');
    set(handles.text_status,'String',text_status);
    disp(text_status);
    return
end
spm('Defaults', 'fMRI');


% Get Parameters from VLSM
DATApath = VLSM.DATApath;
subjlist = VLSM.subjname;
nsubj = length(subjlist);

ROIfolder  = VLSM.ROIfolder;
ROIprefix  = VLSM.ROIprefix;
groupVar   = VLSM.groupVar;
ngrp       = VLSM.ngrp;

% Get Covariates from VLSM input
nCovariates = VLSM.nCovariates;
if nCovariates>0,
    covariateVars = VLSM.covariate.values;
    covariateNames = VLSM.covariate.names;
else
    covariateVars = [];
    covariateNames = [];
end



if ngrp~=2,
    % Print Status on chi2test window
    pause(0.5);
    text_status = sprintf('Error: No. of groups should be 2');
    set(handles.text_status,'String',text_status);
    disp(text_status);
    return
end


% Change 'Run' button color
set(handles.pushbutton_runGroup,'ForegroundColor',[1 1 1]);
set(handles.pushbutton_runGroup,'BackgroundColor',[11 132 199]./256);
pause(0.2);


% Output Path Setup
if nCovariates>0,
    OUTpath = fullfile(DATApath,['logistic_' covariateNames],groupVar); 
else
    OUTpath = fullfile(DATApath,'logistic',groupVar); 
end
mkdir(OUTpath);


% Get Image information
fn_tmp = sprintf('w%s%s.nii',ROIprefix, subjlist{1});
fn_roi = fullfile(DATApath, ROIfolder, fn_tmp);
if ~spm_existfile(fn_roi)
    pause(0.5);
    [p,f,e] = fileparts(fn_roi);
    text_status = sprintf('File "%s" does not exist.', [f e]);
    set(handles.text_status,'String',text_status);
    disp(text_status);
    return;
end
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
LL = zeros(nvox,1);
UL = zeros(nvox,1);
Beta = zeros(nvox,1);
% parfor i=1:nvox,
parfor i=1:nvox,
    dat = data(:,i);
    [B,dev,stats] = mnrfit([dat, covariateVars],group); % mnrfit(X,Y)
    % dat1 = dat(grp(1).idx);
    % dat2 = dat(grp(2).idx);
    % [p, chi2] = chi2tests(dat1, dat2);
    Pval(i) = stats.p(2);  % effects of lesion(yes/no) in predicting disease
    LL(i) = stats.beta(2) - 1.96.*stats.se(2);
    UL(i) = stats.beta(2) + 1.96.*stats.se(2);
    Beta(i) = stats.beta(2);
end


%--------------------------------------------------------------------------
% Write the resulting group comparison
%--------------------------------------------------------------------------

% Get significant voxels
ids = find(Pval<1);


% Write Upper-Limit image
IMG = zeros(vref.dim);
IMG(idvox(ids)) = UL(ids);

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'logistic_UL.nii');
spm_write_vol(v, IMG);


% Write Lower-Limit image
IMG = zeros(vref.dim);
IMG(idvox(ids)) = LL(ids);

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'logistic_LL.nii');
spm_write_vol(v, IMG);


% Write Beta image
IMG = zeros(vref.dim);
IMG(idvox(ids)) = Beta(ids);

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'logistic_beta.nii');
spm_write_vol(v, IMG);


% Write -log10(Puncorr) image
IMG = zeros(vref.dim);
IMG(idvox(ids)) = -log10(Pval(ids));

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'logistic_log10_P_uncorr.nii');
spm_write_vol(v, IMG);


% Write -log10(Pfdr) image
[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(Pval);
IMG = zeros(vref.dim);
IMG(idvox(ids)) = -log10(adj_p(ids));

v = vref;
v.dt = [16 0];
v.fname = fullfile(OUTpath, 'logistic_log10_P_fdr.nii');
spm_write_vol(v, IMG);



% Change 'Run' button color to the original
set(handles.pushbutton_runGroup,'ForegroundColor',[0 0 0]);
set(handles.pushbutton_runGroup,'BackgroundColor',[248 248 248]./256);


% Print Status on chi2test window
pause(0.5);
text_status = sprintf('images of logistic regressions were created.');
set(handles.text_status,'String',text_status);
