function pow_into_r(cfg, subj)
%POW_INTO_R convert power data into R
% only one time point and frequency

% 12/02/19 gives output

%-----------------%
%-input
if nargin == 1
  subj = cfg.subj;
end
%-----------------%

%---------------------------%
%-start log
output = sprintf('(p%02.f) %s started at %s on %s\n', ...
  subj, mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-dir and files
ddir = sprintf('%s%04.f/%s/%s/', cfg.data, subj, cfg.mod, cfg.cond); % data
load(cfg.sens.layout, 'layout')

%-------%
%-get cond names
uniquecond = eq(cfg.test{1}, cfg.test{2});
for i = 1:numel(cfg.test)
  condname{i} = cfg.test{i}(~uniquecond);
end
%-------%
%---------------------------%

%---------------------------%
%-use predefined or power-peaks for areas of interest
if strcmp(cfg.intor.areas, 'manual')
  powpeak = cfg.intor.powpeak;
  
elseif strcmp(cfg.intor.areas, 'powpeak')
  
  %-----------------%
  load([cfg.dcor cfg.proj '_grandpow'], 'gpow')
  powthr = gpow{cfg.intor.poweffect}.powspctrm > cfg.intor.absthr;
  if isempty(find(powthr,1))
    thr = max(gpow{cfg.intor.poweffect}.powspctrm(:)) / 2;
    powthr = gpow{cfg.intor.poweffect}.powspctrm > thr;
    output = sprintf('%sNo significant elec-freq-time with % 4.f threshold. Using new threshold: % 4.f\n', ...
      output, cfg.intor.absthr, thr);
  end
  %-----------------%
  
  %-----------------%
  %-get labels, time, freq above threshold
  x = squeeze(sum(sum(powthr,1),3));
  lgrp_i = findbiggest(x);
  foi = gpow{cfg.intor.poweffect}.freq(lgrp_i);
  
  %-------%
  %-feedback
  s_foi = sprintf('% 7.1f', foi);
  s_foix = sprintf('% 5.f  ', x(lgrp_i));
  %-------%
  
  x = squeeze(sum(sum(powthr,1),2));
  lgrp_i = findbiggest(x);
  toi = gpow{cfg.intor.poweffect}.time(lgrp_i);
  
  %-------%
  %-feedback
  s_toi = sprintf('% 7.1f', toi);
  s_toix = sprintf('% 5.f  ', x(lgrp_i));
  %-------%
  
  x = squeeze(sum(sum(powthr,2),3));
  label = gpow{cfg.intor.poweffect}.label(find(x));
  
  %-------%
  %-feedback
  s_l = sprintf('\t%s', label{:});
  s_lx = sprintf('\t%1.f', x(x > 0));
  %-------%
  %-----------------%
  
  %-----------------%
  %-convert into powpeak
  powpeak(1).time = mean(toi);
  powpeak(1).wndw = range(toi)/2;
  powpeak(1).freq = mean(foi);
  powpeak(1).band = range(foi);
  powpeak(1).name = sprintf('thr_freq%02.fat%04.f', mean(foi), mean(toi)*1e3);
  
  save(cfg.intor.elec, 'label')
  %-----------------%
  
  %-----------------%
  %-output
  output = sprintf('%speakdetected\n freq: %s\n    n: %s\n time: %s\n    n: %s\n elec: %s\n    n: %s\n', ...
    output, s_foi, s_foix, s_toi, s_toix, s_l, s_lx);
  
  h = figure;
  cfg1 = [];
  cfg1.xlim = mean(toi) + [-.5 .5] * range(toi);
  cfg1.ylim = mean(foi) + [-.5 .5] * range(foi);
  cfg1.zlim = [0 cfg.intor.absthr * 1.5];
  cfg1.highlight = 'yes';
  cfg1.highlightchannel = label;
  cfg1.layout = layout;
  ft_topoplotTFR(cfg1, gpow{cfg.intor.poweffect});
  
  %--------%
  %-save and link
  pngname = sprintf('absthr_%1.f_freq%02.fat%04.f', cfg.intor.absthr, mean(foi), mean(toi)*1e3);
  saveas(h, [cfg.log filesep pngname '.png'])
  close(h); drawnow
  
  [~, logfile] = fileparts(cfg.log);
  system(['ln ' cfg.log filesep pngname '.png ' cfg.rslt pngname '_' logfile '.png']);
  %--------%
  %-----------------%
    
end

save([cfg.dcor 'r_powpeak'], 'powpeak') % used by exportneckersd
%---------------------------%

%-------------------------------------%
%-loop over conditions
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
%-----------------%

f = 1; % only first powpeak

dat = '';
for k = 1:numel(cfg.test)
  
  %-----------------%
  %-input and output for each condition
  allfile = dir([ddir cfg.test{k} cfg.endname '.mat']); % files matching a preprocessing
  if isempty(allfile)
    continue
  end
  %-----------------%
  
  %-----------------%
  %-concatenate only if you have more datasets
  if numel(allfile) > 1
    spcell = @(name) sprintf('%s%s', ddir, name);
    allname = cellfun(spcell, {allfile.name}, 'uni', 0);

    dataall = [];
    for i = 1:numel(allname)
      load(allname{i}, 'data')
      data.trialinfo = [data.trialinfo repmat(i, numel(data.trial), 1)];
      dataall{i} = data;
    end
    
    cfg1 = [];
    data = ft_appenddata(cfg1, dataall{:});
    clear dataall
    
  else
    load([ddir allfile(1).name], 'data')
    
  end
  %-----------------%
  
  %-----------------%
  %-pow on peak
  cfg1 = [];
  cfg1.method = 'mtmconvol';
  cfg1.output = 'pow';
  cfg1.taper = 'hanning';
  cfg1.foi = powpeak(f).freq + [-.5:.1:.5] * powpeak(f).band;
  
  cfg1.t_ftimwin = powpeak(f).wndw * ones(numel(cfg1.foi),1);
  cfg1.toi = powpeak(f).time;
  cfg1.feedback = 'none';
  cfg1.keeptrials = 'yes';
  freq = ft_freqanalysis(cfg1, data);
  
  pow = mean(freq.powspctrm,3);
  powlog = mean(log(freq.powspctrm),3);
  logpow = log(mean(freq.powspctrm,3));
  %-----------------%
  
  %-----------------%
  %-write to file
  for t = 1:size(pow,1);
    for e = 1:size(pow,2);
      dat = sprintf('%s%03.f,%s,%1.f,%1.f,%1.f,%1f,%s,%1f,%1f,%1f\n', ....
        dat, ...
        subj, condname{k}, subjday(subj, k), data.trialinfo(t, end), t, data.trialinfo(t, cfg.intor.info), ...
        data.label{e}, pow(t,e), powlog(t,e), logpow(t,e));
    end
  end
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen(cfg.intor.csv, 'a+');
fprintf(fid, dat);
fclose(fid);
%-------------------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('(p%02.f) %s ended at %s on %s after %s\n\n', ...
  subj, mfilename, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([cfg.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%

%-------------------------------------%
%-subfunction FINDBIGGEST
function lgrp_i = findbiggest(x)
i_x = find(x > 0);

i_bnd = find(diff(i_x) ~= 1);
bnd = [1 i_bnd+1; i_bnd numel(i_x)]';

for i = 1:size(bnd,1)
  grp(i) = sum(x(i_x(bnd(i,1)):i_x(bnd(i,2))));
end

[~, lgrp] = max(grp);
lgrp_i = i_x(bnd(lgrp,1)):(i_x(bnd(lgrp,2)));
%-------------------------------------%