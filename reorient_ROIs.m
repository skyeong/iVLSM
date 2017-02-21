subjlist = {'gsj2005002','hkw7588468','kjs7807226',	'gwg7820563','ios3831118','bkl2279252','isg5937842','jhs3122863','jmh7539298','jgy7828866','jsd2638994','khj7835411'};

subjlist = {'cyh7806691','can4154813','cmc5772533','acm5328433','hhm5538505','gic5898129','kch7825264' ,'ljs4027219','hsa2049274','hss7841977',...
'kgm5238144','cjj7825028','hsg7518310','hsc7539643','ceb5163917','cis3621111' ,'gsg7592393','kbg4196068'}

nsubj = length(subjlist);

DATApath = '/Users/skyeong/Downloads/FAC345';
for c=1:nsubj,
    
    f1 = fullfile(DATApath,'diffusion',sprintf('%s.nii',subjlist{c}));
    v1 = spm_vol(f1);
    
    f2 = fullfile(DATApath,sprintf('l%s.img',subjlist{c}));
    v2 = spm_vol(f2);
    I = spm_read_vols(v2);
    
    vout = v2;
    vout.mat = v1.mat;
    fout = fullfile(DATApath,sprintf('l%s.nii',subjlist{c}));
    vout.fname = fout;
    spm_write_vol(vout,I);
end