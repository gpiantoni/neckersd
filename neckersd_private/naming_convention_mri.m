function naming_convention_mri
%NAMING_CONVENTION_MRI copy MRI data into necker's cube
%
% We copy the original data from the lichtmap. I prefer to copy the data
% because the link with the lichtmap might disappear and I want to keep the
% original data. In the case of MRI, the data is already on the server in
% the right structure, but I doubt that the subject names match with the
% other ones. I cannot check it and cannot control it.
%
% However, the PAR/REC on the lichtmap have very original names
%
% here we create a similar structure following the naming convention, with
% orig and raw folders

% 12/02/01 created

%-------------------------------------%
%-move from mri
%-----------------%
%-origin
mridir = '/data1/projects/neckersd/recordings/mri/';
subjd = {'EK' 'HE' 'MS' 'MW' 'NR' 'RW' 'TR' 'WM'};
%-----------------%

%-----------------%
%-SomerenServer
proj = 'neckersd';
rec  = 'vigd';
rawd = 'raw'; % name of the raw directory inside recordings

mod  = 'smri';
cond = 't1';

base = ['/data1/projects/' proj filesep];
recd = [base 'recordings/' rec filesep];
recs = [recd 'subjects/'];
% once the data is on the server, you can just create a symbolic link to it
% into recordings, or you change base into '/data1/'
%-----------------%

for subj = 1:numel(subjd)
  mdir = [mridir subjd{subj} '/mri/'];
  hdrf = dir([mdir '*.hdr']);
  imgf = dir([mdir '*.img']);
  
  cdir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, 'conv'); % conv dir
  cname = sprintf('%s_%04.f_%s_%s', rec, subj, mod, cond);
  
  mkdir(cdir)
  
  system(['ln ' mdir hdrf(1).name ' ' cdir cname '.hdr']);
  system(['ln ' mdir imgf(1).name ' ' cdir cname '.img']);
  
end
%-------------------------------------%

%-------------------------------------%
%-convert into simpler format
for subj = 1:numel(subjd)
  
  cdir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, 'conv'); % conv dir
  cname = sprintf('%s_%04.f_%s_%s', rec, subj, mod, cond);
  cd(cdir)
  
  system(['fslchfiletype NIFTI_GZ ' cname '.img']);
  
end
%-------------------------------------%

%-------------------------------------%
%-create symbolic links
for subj = 1:numel(subjd)
  
  cdir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, 'conv'); % conv dir
  rdir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, rawd); % conv dir
  
  cname = sprintf('%s_%04.f_%s_%s', rec, subj, mod, cond);
  mkdir(rdir)
  
  system(['ln -s ' cdir cname '.nii.gz ' rdir cname '.nii.gz']);
  
end
%-------------------------------------%

