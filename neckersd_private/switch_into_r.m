function switch_into_r(info, opt, subj)
%SWITCH_INTO_R convert power data into R
% only frequency, but maybe more points?
%
% INFO
%  .log
%
% CFG.OPT
%  .cond
%  .freq: two scalars for frequency limit
%  .time: time of interest
%  .wndw: length of time window
%  .powcorr: which column from trialinfo

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
    disp(cond2read)
    [data] = load_data(info, subj, cond2read);
    if isempty(data)
      output = sprintf('%sCould not find any file for condition %s\n', ...
        output, cond2read);
      continue
    end
    %---------------------------%
    
    %---------------------------%
    %-----------------%
    %-compute number of frequency
    nfreq = ceil(diff(opt.freq) * opt.wndw) + 1;
    %-----------------%
    
    powspctrm = [];%zeros(numel(data.trial), numel(opt.channel), nfreq, numel(opt.time));
    
    for t = 1:numel(opt.time)
      
      %-----------------%
      %-select data in time window
      datasel = data;
      sel1 = nearest(data.time{1}, opt.time(t) - opt.wndw / 2);
      sel2 = sel1 + round(opt.wndw * data.fsample) - 1;
      for tr = 1:numel(data.time)
        datasel.time{tr} = datasel.time{tr}(:,sel1:sel2);
        datasel.trial{tr} = datasel.trial{tr}(:,sel1:sel2);
      end
      %-----------------%
      
      cfg = [];
      cfg.method = 'mtmfft';
      cfg.output = 'pow';
      cfg.taper = 'hanning';
      cfg.foilim = opt.freq;
      cfg.channel = opt.channel;
      cfg.feedback = 'none';
      cfg.keeptrials = 'yes';
      freq = ft_freqanalysis(cfg, datasel);
      powspctrm = cat(4, powspctrm, freq.powspctrm);
    end
    
    pow  = permute(    mean(mean(powspctrm,3),2) , [1 4 2 3]);
    pow1 = permute(log(mean(mean(powspctrm,3),2)), [1 4 2 3]);
    pow2 = permute(mean(log(mean(powspctrm,2)),3), [1 4 2 3]);
    pow3 = permute(mean(log(mean(powspctrm,3)),2), [1 4 2 3]);
    pow4 = permute(mean(mean(log(powspctrm),3),2), [1 4 2 3]);
    
    trl = unique(freq.trialinfo(:,1));
    ntrl = numel(trl);
    
    for t = 1:ntrl
      itrl = trl(t);
      iseg = find(data.trialinfo(:,1) == itrl);
      
      if opt.trl_index
        idur = iseg(1);
      else
        idur = t;
      end
      
      for toi = 1:numel(opt.time)
        
        dat = sprintf(['%s', ...
          '%03d,%s,%d,%d,%d,%1f,%1.3f,' ...
          '%1f,%1f,%1f,%1f,%1f\n'], ....
          dat, ...
          subj, condname{k}, subjday(subj, k), i, t, data.trialinfo(idur, opt.powcorr), opt.time(toi),...
          mean(pow(iseg,toi)), mean(pow1(iseg,toi)), mean(pow2(iseg,toi)), mean(pow3(iseg,toi)), mean(pow4(iseg,toi)));
      end
      
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
