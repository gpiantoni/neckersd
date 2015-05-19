function decay_into_r(info, opt, subj)
%DECAY_INTO_R convert power data into R
% only one time point and frequency
% Similar to between_into_r, but don't average power
%
% INFO
%  .log
%
% CFG.OPT
%  .cond
%  .freq: two scalars for frequency limit
%  .infocol: which column from trialinfo
%  .trl_index: use true or false trial index

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%-------------------------------------%
%-loop over conditions

if ~isfield(opt, 'trl_index'); opt.trl_index = true; end

%-----------------%
%-assign day, based on subj number and condition
subjday = [2 1 % EK
  1 2 % HE
  1 2 % MS
  1 2 % MW
  2 1 % NR
  2 1 % RW
  1 2 % TR
  2 1]; % WM

%-------%
%-get cond names
uniquecond = eq(opt.cond{1}, opt.cond{2});
for i = 1:numel(opt.cond)
  condname{i} = opt.cond{i}(~uniquecond);
end

csvname = regexprep(opt.cond{1}(uniquecond), '*', '');
%-------%
%-----------------%

%-------------------------------------%
%-loop over conditions
dat = '';

for k = 1:numel(opt.cond)
  
  for i = 1:5
    
    %---------------------------%
    %-read data
    cond2read = regexprep(opt.cond{k}, '*', sprintf('_%03d', i));
    [data] = load_data(info, subj, cond2read);
    if isempty(data)
      output = sprintf('%sCould not find any file for condition %s\n', ...
        output, cond2read);
      continue
    end
    %---------------------------%
    
    %---------------------------%
    cfg = [];
    cfg.method = 'mtmfft';
    cfg.output = 'pow';
    cfg.taper = 'hanning';
    cfg.foilim = opt.freq;
    cfg.channel = opt.channel;
    cfg.feedback = 'none';
    cfg.keeptrials = 'yes';
    freq = ft_freqanalysis(cfg, data);
    
    pow  =     mean(mean(freq.powspctrm,3),2);
    pow1 = log(mean(mean(freq.powspctrm,3),2));
    pow2 = mean(log(mean(freq.powspctrm,2)),3);
    pow3 = mean(log(mean(freq.powspctrm,3)),2);
    pow4 = mean(mean(log(freq.powspctrm),3),2);
    
    for t = 1:size(freq.trialinfo,1) % n trials
      
      dat = sprintf(['%s', ...
        '%03d,%s,%d,%d,%d,%1f,%1.3f,' ...
        '%1f,%1f,%1f,%1f,%1f\n'], ....
        dat, ...
        subj, condname{k}, subjday(subj, k), i, data.trialinfo(t, 1), data.trialinfo(t, opt.infocol), 0, ... % 0 is time, because it changes for switch_into_r
        pow(t,:), pow1(t,:), pow2(t,:), pow3(t,:), pow4(t,:));
      
    end
    %---------------------------%
    
  end
  
end
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen([info.dcor csvname '.csv'], 'a+');
fprintf(fid, dat);
fclose(fid);
%-------------------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('%s (%04d) ended at %s on %s after %s\n\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([info.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%