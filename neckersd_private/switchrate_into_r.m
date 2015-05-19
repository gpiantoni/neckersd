function switchrate_into_r(cfg, subj)
%SWITCHRATE_INTO_R write switchrate into R for nicer calculations

%---------------------------%
%-dir and files
ddir = sprintf('%s%04.f/%s/%s/', cfg.data, subj, cfg.mod, cfg.nick); % data

%-------%
%-get cond names
uniquecond = eq(cfg.switchrate.cond{1}, cfg.switchrate.cond{2});
for i = 1:numel(cfg.switchrate.cond)
  condname{i} = cfg.switchrate.cond{i}(~uniquecond);
end
%-------%
%---------------------------%

%-------------------------------------%
%-loop over test
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

getdur = @(x)[x(strcmp({x.type}, 'switch')).duration];
dat = '';

for k = 1:numel(cfg.switchrate.cond)
  
  %-----------------%
  %-input and output for each condition
  allfile = dir([ddir cfg.switchrate.cond{k} cfg.endname '.mat']); % files matching a preprocessing
  %-----------------%
  
  %-----------------%
  %-read data and concat dat
  if numel(allfile) > 0
    
    %-------%
    %-loop over sessions
    for i = 1:numel(allfile)
      load([ddir allfile(i).name], 'data')
      
      event = ft_findcfg(data.cfg, 'event');
      alldur = getdur(event);
      
      %-write to file
      for t = 1:numel(alldur)
        dat = sprintf('%s%1.f,%s,%1.f,%1.f,%1f\n', ....
          dat, subj, condname{k}, subjday(subj, k), i, alldur(t));
      end
    end
    %-------%
    
  else
    output = sprintf('%sCould not find any file in %s for test %s\n', ...
      output, ddir, cfg.switchrate.cond{k});
    
  end
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen(cfg.switchrate.csv, 'a+');
fprintf(fid, dat);
fclose(fid);
%-------------------------------------%