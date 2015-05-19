function switchrate(cfg)
%SWITCHRATE read the events (not the trials) and make nice stats in R

%---------------------------%
%-start log
output = sprintf('%s began at %s on %s\n', ...
  mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%- run switchrate.R
rdir = [cfg.scrp cfg.proj '_private/rfunctions/'];
funname = [rdir 'switchrate.R'];

args{1} = cfg.switchrate.csv;
args{2} = sprintf('%03.f', cfg.switchrate.dur.min*10);
args{3} = sprintf('%03.f', cfg.switchrate.dur.max*10);
args{4} = sprintf('%03.f', cfg.switchrate.dur.steps*10);
args{5} = sprintf('%03.f', cfg.switchrate.dur.bw*10);
args{6} = sprintf('%s/switchrate_min%s_max%s_steps%s_bw%s.png', ...
  cfg.log, args{2}, args{3}, args{4}, args{5}); % PDF?
args{7} = [cfg.log '.txt'];

s_args = sprintf(' %s', args{:});
system(['Rscript ' funname ' ' s_args]);
%---------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('%s ended at %s on %s after %s\n\n', ...
  mfilename, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([cfg.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%