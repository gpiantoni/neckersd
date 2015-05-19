function exportneckersd(info, cfg)
%EXPORTNECKERSD export info from neckersd

%-------------------------------------%
%-general
[~, logname] = fileparts(info.log);
output = [logname ','];

for i = 1:numel(info.run)
  output = [output sprintf('%d %s ', info.run(i), cfg(info.run(i)).function)];
end
%-------------------------------------%

%-------------------------------------%
%-from cfg to log
output = [output sprintf(',%d', cfg(9).opt.freq(1), cfg(9).opt.freq(2))];
output = [output sprintf(',%d,', numel(cfg(9).opt.channel))];
output = [output cfg(11).opt.rfun(2).args{2} ',']; % pow
output = [output sprintf('%f,', cfg(10).opt.wndw)];
%-------------------------------------%

%-------------------------------------%
%-read results
csvinfo = {'main' 'predict' 'mediation' 'singlesubj'};
for i = 1:numel(csvinfo)
  csvfile = [info.log filesep 'output_' csvinfo{i} '.csv'];
  
  if exist(csvfile, 'file')
    output = [output csvinfo{i} ','];
    
    lmerinfo = dlmread(csvfile);
    output = [output  sprintf('%f,', lmerinfo)];
  end
  
end
%-----------------%
%-prepare output
% MAIN
% 1- lmer powlog only ns
% 2- lmer powlog only sd
% 3- lmer powlog X cond: powlog
% 4- lmer powlog X cond: cond
% 5- lmer powlog X cond: interaction
 
% PREDICT
% 1- most significant value
% 2- index of the most significant value
% 3- # of significant values at 0.05
% 4- # of significant values at 0.1

% MEDIATION
% 1- z-value for mediation

% SINGLE-SUBJ
% 1- p-value for alpha
% 2- p-value for perceptual duration
% 3- p-value for correlation
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen(cfg(end).opt.csvf, 'a+');
fwrite(fid, output);
fprintf(fid, '\n');
fclose(fid);
%-------------------------------------%
