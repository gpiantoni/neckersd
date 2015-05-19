function seldata_necker(cfg, subj)
%SELDATA_NECKER copy necker data into folder

mversion = 2;
%02 12/02/07 added seldata to select channels
%01 12/02/04 copy necker data into folder

%-----------------%
%-input
if nargin == 1
  subj = cfg.subj;
end
%-----------------%

%---------------------------%
%-start log
output = sprintf('(p%02.f) %s (v%02.f) started at %s on %s\n', ...
  subj, mfilename,  mversion, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-dir and files
ddir = sprintf('%s%04.f/%s/%s/', cfg.data, subj, cfg.mod, cfg.nick); % data
if isdir(ddir); rmdir(ddir, 's'); end
mkdir(ddir)

%-----------------%
%-read sensors
[~, ~, ext] = fileparts(cfg.sens.file);
if strcmp(ext, '.mat')
  load(cfg.sens.file, 'sens')
else
  sens = ft_read_sens(cfg.sens.file);
  sens.label = upper(sens.label); % <- EGI labels are uppercase, but the elec file is lowercase
end
%-----------------%

subjcond = [2 1 % EK
  1 2 % HE
  1 2 % MS
  1 2 % MW
  2 1 % NR
  2 1 % RW
  1 2 % TR
  2 1]; % WM
%---------------------------%

%---------------------------%
%-loop over conditions
preICAdir  = [cfg.base 'recordings/' 'FTdata/'];
postICAdir = [cfg.base 'recordings/' 'after_ICA/'];

load(cfg.sens.file, 'elec')

for i = 1:10
  if ~(subj == 7 && i == 10) % missing
        
    %-----------------%
    %-read info
    load(sprintf('%ssubj%1.f_%02.f', preICAdir, subj, i))
    name_pre = sprintf('data_%1.f_%02.f', subj, i);
    data_pre = eval(name_pre);
    events = ft_findcfg(data_pre.cfg, 'event');
    
    load(sprintf('%ssubj%1.f_%02.f', postICAdir, subj, i))
    name_post = sprintf('clean_data_%1.f_%02.f', subj, i);
    data_post = eval(name_post);
    %-----------------%
    
    %-----------------%
    %-prepare data
    data = data_post;
    trl = ft_findcfg(data_post.cfg, 'trl');

    hdr = [];
    hdr.Fs = data.fsample;
    hdr.nSamples = trl(end,2);
    data.cfg.event = fixneckerevent(events, hdr);
    data.sampleinfo = trl(:,1:2);
    
    data.label = elec.label';
    data.elec = elec;
    %-----------------%
    
    %-----------------%
    %-prepare name
    if i <= 5 % note that TR has only 9 sessions. the last session of sleep deprivation is missing
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
    
    rawname = sprintf('%s_%04.f_%s_%s-%s_%03.f_%s', ...
      cfg.rec, subj, cfg.mod, cfg.nick, nssd, sess, mfilename);
    disp(rawname)
    data = ft_selectdata(data, 'channel', cfg.seldata.channel);
    save([ddir rawname], 'data')
    %-----------------%
    
  end
end
%---------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('(p%02.f) %s (v%02.f) ended at %s on %s after %s\n\n', ...
  subj, mfilename, mversion, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([cfg.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%