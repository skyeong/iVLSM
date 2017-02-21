function reslice_img(vref, image_to_reslice)

source = image_to_reslice;
target = vref;
fns = char(target,source);

flags = struct('interp',0,'mask',0,'mean',0,'which',1,'wrap',[0 0 0]');
spm_reslice(fns,flags);
