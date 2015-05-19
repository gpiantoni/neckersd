function source_into_r(info, opt, subj)
%SOURCE_INTO_R calculate power at the source level and use it for
%correlation
% only one time point and frequency
%
% INFO
%  .log
% 
% CFG.OPT
%  .freq: center frequency
%  .tapsmofrq: smoothing 
%  .dics: options for dics, such as
%    .lambda
%  .noise: compute noise
%  .log: take log
%  .powcorr: which column from trialinfo
%
% TODO: use a baseline condition

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

[vol, lead, sens] = load_headshape(info, subj);

%-------------------------------------%
%-loop over conditions
maincond = 'ns';

fid = fopen(sprintf('%ssource_%04d.csv', info.dcor, subj), 'w+');

for k = 1:numel(opt.cond) 
  
  cond = opt.cond{k};
  
  %---------------------------%
  %-read data
  [data badchan] = load_data(info, subj, cond);
  if isempty(data)
    output = sprintf('%sCould not find any file for condition %s\n', ...
      output, cond);
    continue
  end
  %---------------------------%
  
  %---------------------------%
  %-remove bad channels from leadfield
  datachan = ft_channelselection([{'all'}; cellfun(@(x) ['-' x], badchan, 'uni', false)], data.label);
  [leadchan] = prepare_leadchan(lead, datachan);
  %---------------------------%
  
  %---------------------------%
  %-freq analysis
  tmpcfg = [];
  tmpcfg.method = 'mtmfft';
  tmpcfg.output = 'fourier';
 
  tmpcfg.taper = 'dpss';
  tmpcfg.foi = opt.freq;
  tmpcfg.tapsmofrq = opt.tapsmofrq;
  
  tmpcfg.feedback = 'none';
  tmpcfg.channel = datachan;

  freq = ft_freqanalysis(tmpcfg, data);
  %---------------------------%

  %---------------------------%
  %-source analysis (all trials)
  haslambda = isfield(opt.dics, 'lambda') && ~isempty(opt.dics.lambda);
  
  tmpcfg = [];
  
  tmpcfg.frequency = opt.freq;
  
  tmpcfg.method = 'dics';
  tmpcfg.dics = opt.dics;
  
  tmpcfg.dics.keepfilter = 'yes';
  tmpcfg.dics.feedback = 'none';
  
  tmpcfg.vol = vol;
  tmpcfg.grid = leadchan;
  tmpcfg.elec = sens;
  
  if haslambda && isfield(opt, 'noise') && opt.noise
    tmpcfg.projectnoise = 'yes';
  end
  
  sou = ft_sourceanalysis(tmpcfg, freq);
  %---------------------------%
  
  %---------------------------%
  %-single trial analysis
  tmpcfg.grid.filter  = sou.avg.filter;
  tmpcfg.rawtrial = 'yes';
  soucorr = ft_sourceanalysis(tmpcfg, freq);
  pow = [soucorr.trial.pow]';
  %---------------------------%

  %---------------------------%
  %-use noise if necessary
  if haslambda && isfield(opt, 'noise') && opt.noise
    noise = cat(1, soucorr.trial.noise);
    pow = pow ./ noise; % definition of NAI
  end
  %---------------------------%
  
  %---------------------------%
  %-log
  if isfield(opt, 'log') && opt.log
    pow = log(pow);
  end
  %---------------------------%
  
  %---------------------------%
  %-prepare CSV
  trl = unique(freq.trialinfo(:,1));
  ntrl = numel(trl);
  
  for t = 1:ntrl
    itrl = trl(t);
    iseg = find(data.trialinfo(:,1) == itrl);
    
    for e = 1:size(pow,2);
      
      if ~any(isnan(pow(iseg, e)))
        text2write = sprintf('%03d,%s,%d,%d,%f,%d,%f\n', ....
          subj, maincond, k, t, data.trialinfo(iseg(1), opt.powcorr), ...
          e, mean(pow(iseg, e))); % mean over the segments
        
        fprintf(fid, text2write);
      end
      
    end
  end
  %---------------------------%
  
end
%-----------------%

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