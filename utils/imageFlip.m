function imageFlip

[FileName,PathName,FilterIndex] = uigetfile({'*.nii';'*.img'},'Select images to flip','MultiSelect', 'on');

% Count number of files
if iscell(FileName)
    nfiles = length(FileName);
else
    nfiles = 1;
end

for i=1:nfiles,
    
    % when multiple files were selected
    if iscell(FileName),
        fn=fullfile(PathName,FileName{i});
    else  % when a single file was selected
        fn=fullfile(PathName,FileName);
    end
    
    [p,f,e]=fileparts(fn);
    
    vin = spm_vol(fn);
    IMG = spm_read_vols(vin);
    vout = vin;
    vout.fname=fullfile(p,[f '_flip' e]);
    spm_write_vol(vout,IMG(end:-1:1,:,:));
end



% fn='test1.nii';
%
% vin = spm_vol(fn);
% IMG = spm_read_vols(vin);
% vout = vin;
% vout.fname='test_flip.nii';
% spm_write_vol(vout,IMG(end:-1:1,:,:));