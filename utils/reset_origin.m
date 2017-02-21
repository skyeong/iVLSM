% Excel file and project path
fn_xls = '/Users/skyeong/Desktop/vlsm_kuh/161006_VLSM.xlsx';
PROJpath = '/Users/skyeong/Desktop/vlsm_kuh';

% Folder names
old_ROI_folder = 'ROI_mricro';
new_ROI_folder = 'ROI';
structure_folder = 'structure';


%% Do not change below
[a,b,data] = xlsread(fn_xls);
subjlist = data(2:end,2);
nsubj = length(subjlist);

for c=1:nsubj,
    subjname = subjlist{c};
    
    % Read ROI
    fn_ROI = fullfile(PROJpath,old_ROI_folder,['l' subjname '.img']);
    vo_ROI = spm_vol(fn_ROI);
    ROI = spm_read_vols(vo_ROI);
    
    % Load T1
    fn_T1 = fullfile(PROJpath,structure_folder,[subjname '.nii']);
    vo_T1 = spm_vol(fn_T1);
    
    % Re-write ROIs with new origins
    vout = vo_ROI;
    vout.mat = vo_T1.mat;
    OUTpath = fullfile(PROJpath,new_ROI_folder); mkdir(OUTpath);
    vout.fname=fullfile(PROJpath,new_ROI_folder,['l' subjname '.nii']);
    spm_write_vol(vout,ROI);
end