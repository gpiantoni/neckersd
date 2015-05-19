function naming_convention
%NAMING_CONVENTION copy only necker cube data into our recording folder
%
% We copy the original data from the lichtmap. I prefer to copy the data
% because the link with the lichtmap might disappear and I want to keep the
% original data. The best solution is to have all the data on the server
% according to the correct naming structure. This is just a quick
% workaround
%
% here we create a similar structure following the naming convention, with
% orig and raw folders
%
% If you want to use two conditions, you need to be careful. There are 2
% steps: 1. orange -> orig 2. orig -> raw
% However, step 2. is not very smart, it just copy the data based on the
% name, without reading the markers. So, you cannot run step 2. when the
% folder orig contains data from both neckersd and resting (or any other
% condition). So, run like this:
% Run 1. and 2. for necker
% delete data only in folder orig (the links in raw are now broken)
% Run 1. and 2. for resting
% Run 1. for only necker

% 12/08/02 adapted for resting state as well. Not completely, there are
%          some missing markers and problems. I'm using the cleaned-up data
%          for the moment
% 12/02/01 created

%-------------------------------------%
%-info
%-----------------%
%-lichtmap
origd = '/mnt/orange/romeijn/hdEEG fMRI Experiment/hdEEG data/';
subjd = {'EK240708/PAT_12' 'HE030608/PAT_6' 'MS190708/PAT_11' 'MW200608/PAT_8' ...
  'NR090608/PAT_7' 'RW290508/PAT_4' 'TR280508/PAT_3' 'WM191008/PAT_13'};

mkr = [102 103 104 105]; % mkr = [100 101];

subjcond = [2 1 % EK
1 2 % HE
1 2 % MS
1 2 % MW
2 1 % NR
2 1 % RW
1 2 % TR
2 1]; % WM
%-----------------%

%-----------------%
%-SomerenServer
proj = 'neckersd';
rec  = 'vigd';
rawd = 'raw'; % name of the raw directory inside recordings

mod  = 'eeg';
cond = 'necker'; % cond = 'resting';

base = ['/data1/projects/' proj filesep];
recd = [base 'recordings/' rec filesep];
recs = [recd 'subjects/'];
% once the data is on the server, you can just create a symbolic link to it
% into recordings, or you change base into '/data1/'
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-first we copy everything into orig
for subj = 1:numel(subjd)
  
  fprintf('subj%04.f (%s): \n', subj, subjd{subj})
  ldir = [origd subjd{subj} filesep];
  odir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, 'orig'); % orig dir
  
  if ~isdir(odir); mkdir(odir); end
  
  trcfile = dir([ldir '*TRC']);
  allnecker = 0;
  
  %---------------------------%
  %-loop over files
  for i = 1:numel(trcfile)
    
    warning off
    evt = ft_read_event([ldir trcfile(i).name]);
    warning on
    
    %-----------------%
    %-does the file contain necker's specific markers?
    isnecker = false;
    
    if ~isempty(evt)
      for m = 1:numel(mkr)
        nmkr = numel(find([evt.value] == mkr(m)));
        if nmkr > 1 % EEG_99.TRC has one 102 and one 103, EEG_336.TRC has one 102
          isnecker = true;
          fprintf('   %s (%s) mkr% 3.f:% 3.f\n', trcfile(i).name, trcfile(i).date, mkr(m), nmkr);
        end
      end
      fprintf('\n');
    end
    %-----------------%
    
    %-----------------%
    %-if necker, copy to orig
    if isnecker
      allnecker = allnecker + 1;
      system(['cp ''' [ldir trcfile(i).name] ''' ' odir]);
    end
    %-----------------%
    
  end
  %---------------------------%

  fprintf('  % 2.f files with %s data', allnecker, cond)
  if allnecker ~= 10
    fprintf(' <- NUMBER OF DATASET IS NOT 10!!!!');
  end
  fprintf('\n\n');
    
end  
%-------------------------------------%

%-------------------------------------%
%-then move into raw folder
for subj = 1:numel(subjd)
  
  %-----------------%
  %-directory
  odir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, 'orig'); % orig dir
  rdir = sprintf('%s%04.f/%s/%s/', recs, subj, mod, rawd); % raw dir
  if ~isdir(rdir); mkdir(rdir); end
  %-----------------%
  
  %-----------------%
  %-this extra code seems complicated, but it takes care of one rare
  % problem. For subj 0006, the datasets are called EEG_63.TRC ...
  % EEG_100.TRC (there is no trailing zero). So EEG_100.TRC is before
  % EEG_63.TRC, which is not correct. Here we use the number to order the
  % datesets
  trcfile = dir([odir '*TRC']);
  
  eeg_index = zeros(numel(trcfile),1);
  for i = 1:numel(trcfile)
    eeg_index(i) = str2double(trcfile(i).name(5:end-4));
  end
  [~, ieeg] = sort(eeg_index);
  %-----------------%
  
  %---------------------------%
  %-loop over files
  for i = 1:numel(trcfile)
    
    %-----------------%
    %-prepare name
    if i <= 5 % note that TR has only 9 sessions. It's missing one session of the sleep deprivation period
      sess = i;
      day  = 1;
    else
      sess = i - 5;
      day  = 2;
    end
    
    if subjcond(subj, day) == 1
      nssd = 'ns';
    else
      nssd = 'sd';
    end
    
    rawname = sprintf('%s_%04.f_%s_%s-%s_%03.f.TRC', ...
      rec, subj, mod, cond, nssd, sess);
    %-----------------%
    
    %-----------------%
    %-symbolic link
    fprintf('  %s  %s\n', trcfile(ieeg(i)).name, rawname);
    system(['ln -s ' odir trcfile(ieeg(i)).name ' ' rdir rawname]);
    %-----------------%
    
  end
  %---------------------------%
  
end
%-------------------------------------%