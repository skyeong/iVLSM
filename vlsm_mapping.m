function vlsm_mapping(handles)
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
set(handles.pushbutton_vlsm,'ForegroundColor',[1 1 1]);
set(handles.pushbutton_vlsm,'BackgroundColor',[11 132 199]./256);
pause(0.2);


% Get Parameters from VLSM
DATApath = VLSM.DATApath;
subjlist = VLSM.subjname;
nsubj    = length(subjlist);
groupVar = VLSM.groupVar;

ROIfolder = VLSM.ROIfolder;
ROIprefix = VLSM.ROIprefix;

medvars   = VLSM.medvars;
nvars     = length(medvars);
nMinSubj  = VLSM.nMinSubj;

% Statistical Methods for VLSM
statMethods = VLSM.statMethods;


% Extract Medical Data
[~,~,xls] = xlsread(VLSM.inputFile);
hdr = xls(1,:);
dat = xls(2:end,:);
beh = zeros(nsubj,nvars);
for i=1:nvars,
    for j=1:length(hdr),
        if strcmp(hdr{j},medvars{i}),
            beh(:,i) = cell2mat(dat(:,j));
        end
    end
end

if size(beh,2)~=length(medvars),
    errordlg('Check your variable name.');
end


% Load reference
fn_tmp = sprintf('w%s%s.nii',ROIprefix,subjlist{1});
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
    
    idx = intersect(idbrainmask, idroi);
    IMG(idx) = IMG(idx) + 1;
end


% Collect Data from All Subjects
idvox = find(IMG>=nMinSubj); clear IMG;
nvox = length(idvox);
data = zeros(nsubj,nvox);
for c=1:nsubj,
    fn_tmp = sprintf('w%s%s.nii',ROIprefix, subjlist{c});
    fn_roi = fullfile(DATApath, ROIfolder, fn_tmp);
    vo = spm_vol(fn_roi);
    I = spm_read_vols(vo);
    data(c,:) = I(idvox);
end

Pval = zeros(nvox,nvars);
Stat = zeros(nvox,nvars);
for i=1:nvox,
    dat = data(:,i);
    if sum(dat)<nMinSubj, continue; end;
    for j=1:nvars,
        idg1 = find(dat>0.9);
        idg0 = find(dat<0.1);
        
        if strcmpi(statMethods,'ttest'),
            [h,p,ci,stat] = ttest2(beh(idg1,j), beh(idg0,j));
            statValue = stat.tstat;
        elseif strcmp(statMethods,'mw'),
            [p,h,stat] = ranksum(beh(idg1,j), beh(idg0,j));
            statValue = stat.zval;
        end
        
        Stat(i,j) = statValue;
        Pval(i,j) = p;
    end
end



% Write the resulting group comparison
OUTpath = fullfile(DATApath,'symptom',groupVar); mkdir(OUTpath);

for i=1:nvars,

    % log10(p): output file name
    if strcmpi(statMethods,'ttest'),
        fn_Puncorr = sprintf('ttest_%s_log10_P_uncorr.nii',medvars{i});
        fn_Pfdr    = sprintf('ttest_%s_log10_P_fdr.nii',medvars{i});
    elseif strcmp(statMethods,'mw'),
        fn_Puncorr = sprintf('MWUtest_%s_log10_P_uncorr.nii',medvars{i});
        fn_Pfdr    = sprintf('MWUtest_%s_log10_P_fdr.nii',medvars{i});
    end
    
    %----------------------------------------------------------------------
    % Write Uncorrected P-value
    %----------------------------------------------------------------------
    idvalid = find(Stat(:,i)~=0);
    IMG = zeros(vref.dim);
    IMG(idvox(idvalid)) = -log10(Pval(idvalid,i)+eps);
    
    % Write Images
    v = vref;
    v.dt = [16 0];
    v.fname = fullfile(OUTpath, fn_Puncorr);
    spm_write_vol(v, IMG);
    
    %----------------------------------------------------------------------
    % Write FDR P-value
    %----------------------------------------------------------------------
    [h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(Pval(idvalid,i));
    IMG = zeros(vref.dim);
    IMG(idvox(idvalid)) = -log10(adj_p(:)+eps);
    
    % Write Images
    v = vref;
    v.dt = [16 0];
    v.fname = fullfile(OUTpath, fn_Pfdr);
    spm_write_vol(v, IMG);
    
    
    
    %----------------------------------------------------------------------
    % Statistical Maps: output file name
    %----------------------------------------------------------------------
    if strcmpi(statMethods,'ttest'),
        fn_stat = sprintf('ttest_%s_tvalue.nii',medvars{i});
    elseif strcmp(statMethods,'mw'),
        fn_stat = sprintf('MWUtest_%s_zvalue.nii',medvars{i});
    end
    
    % Get significant voxels
    IMG = zeros(vref.dim);
    IMG(idvox) = Stat(:,i);
    
    % Write Images
    v = vref;
    v.dt = [16 0];
    v.fname = fullfile(OUTpath, fn_stat);
    spm_write_vol(v, IMG);
    
end

% Change 'Run' button color to the original
set(handles.pushbutton_vlsm,'ForegroundColor',[0 0 0]);
set(handles.pushbutton_vlsm,'BackgroundColor',[248 248 248]./256);

% Print Status on VLSM window
pause(0.5);
text_status = sprintf('images for lesion-symptom mapping were created.');
set(handles.text_status,'String',text_status);
