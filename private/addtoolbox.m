function output = addtoolbox(info)
% add various toolbox:
%   - fieldtrip
%
%   - gtoolbox
%
%   - eventbased
%   - mri2lead
%   - detectsleep (and spm8)
%   - dti
%
%   - project specific (with subdirectories)
% The project-specific folder should be called [info.nick '_private']

[~, host] = system('hostname');
if strcmp(host(end-12:end-1), 'partners.org')
  tbox_dir = '/PHShome/gp902/toolbox/';
else
  tbox_dir = '/data1/toolbox/';
end

ftpath = [tbox_dir 'fieldtrip/']; % fieldtrip (git)
spmpath = [tbox_dir 'spm8/'];

%-------------------------------------%
%-FIELDTRIP (always necessary)
%-----------------%
%-addpath
addpath(ftpath)
global ft_default
ft_default.checksize = Inf; % otherwise it deletes cfg field which are too big
ft_defaults
addpath([ftpath 'qsub/'])
%-----------------%

%-----------------%
%-get fieldtrip version
try % so many thing can go wrong here
  [~, ftver] = system(['git --git-dir=' ftpath '.git log |  awk ''NR==1'' | awk ''{print $2}''']);
catch ME
  ftver = ME.message;
end
output = sprintf('fieldtrip:\t%s', ftver);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-GERMAN'S TOOLBOX (called eegcore)
gpath = [info.scrp 'eegcore/']; % eegcore (bitbucket, with subdirectories)

if isdir(gpath)
  %-----------------%
  %-add gtool toolbox (here, otherwise matlab does not recognize "import"
  % statement in subfunctions) and remove matlab_bgl, because one function
  % has the same name as a built-in functions, giving tons of warnings
  oldpath = genpath(gpath);
  dirs = regexp(oldpath, ':', 'split');
  goodpath = dirs(cellfun(@isempty, regexp(dirs, 'matlab_bgl')));
  addpath(sprintf('%s:', goodpath{:}))
  %-----------------%
  
  %-----------------%
  %-get gtoolbox version
  try % so many thing can go wrong here
    [~, gver] = system(['hg --debug tags --cwd ' gpath ' | awk ''{print $2}''']);
  catch ME
    gver = ME.message;
  end
  outtmp = sprintf('eegcore:\t%s', gver);
  output = [output outtmp];
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-POTENTIAL TOOLBOXES
%---------------------------%
%-check which toolboxes are present (git)
toolbox = {'eventbased' 'detectsleep' 'mri2lead' 'dti' [info.nick '_private']};
dirtools = dir(info.scrp);
toolbox = intersect(toolbox, {dirtools.name}); % only those that are present
%---------------------------%

%---------------------------%
%-add present toolbox
for i = 1:numel(toolbox)
  
  tpath = [info.scrp toolbox{i} filesep];
  addpath(genpath(tpath)) % with subdirectories
  
  %-----------------%
  %-get git version
  try % so many thing can go wrong here
    [~, tver] = system(['git --git-dir=' tpath '.git log |  awk ''NR==1'' | awk ''{print $2}''']);
  catch ME
    tver = ME.message;
  end
  outtmp = sprintf('%s:\t%s', toolbox{i}, tver);
  output = [output outtmp];
  %-----------------%
  
  %-----------------%
  %-add SPM if using detectsleep
  if strcmp(toolbox{i}, 'detectsleep')
    
    addpath(spmpath)
    spm defaults eeg
    
    %-------%
    %-avoid conflict between spm8 and fieldtrip
    % remove folders that have both spm8 and fieldtrip (external of spm)
    oldpath = matlabpath;
    dirs = regexp(oldpath, ':', 'split');
    goodpath = dirs(cellfun(@isempty, regexp(dirs, 'fieldtrip')) | cellfun(@isempty, regexp(dirs, 'spm8')));
    matlabpath(sprintf('%s:', goodpath{:}))
    %-------%
    
  end
  %-----------------%
  
end
%---------------------------%
%-------------------------------------%