function neckersd(cfgin)

%-------------------------------------%
%-INFO--------------------------------%
%-------------------------------------%
info = info_neckersd;

%-----------------%
%-uncomment here if necessary
% if isdir(info.qlog); rmdir(info.qlog, 's'); end; mkdir(info.qlog); 
% if isdir(info.dpow); rmdir(info.dpow, 's'); end; mkdir(info.dpow);
% if isdir(info.dcor); rmdir(info.dcor, 's'); end; mkdir(info.dcor);
%-----------------%

%-----------------%
%-subjects index and step index
info.subjall = 1:8;
info.run = cfgin.run;

info.nooge = [3:17];
info.sendemail = false;
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-CFG---------------------------------%
%-------------------------------------%
%---------------------------%
%-common
% cfgin.alphafreq = [7 11];
% cfgin.chan = {'E25' 'E26' 'E27' 'E28' 'E40' 'E41' 'E42' 'E43' 'E44'};
% cfgin.chan = {'E25' 'E26' 'E27' 'E28' 'E40' 'E41' 'E42' 'E43' 'E44' 'E53' 'E54' 'E55' 'E56' 'E57'};
% cfgin.chan = {'E13' 'E25' 'E26' 'E27' 'E28' 'E40' 'E41' 'E42' 'E43' 'E44' 'E53' 'E54' 'E55' 'E56' 'E57'};
% chan = {'E12' 'E13' 'E14' 'E25' 'E26' 'E27' 'E28' 'E40' 'E41' 'E42' 'E43' 'E44' 'E53' 'E54' 'E55' 'E56' 'E57'};
chan = cfgin.chan;
alphafreq = cfgin.alphafreq;
% cfgin.pow = 'pow2';
% cfgin.wndw = .3;
%---------------------------%

%---------------------------%
%-PREPROCESSING
%-----------------%
%-01: select data
st = 1;
cfg(st).function = 'seldata';
cfg(st).step = 'subj';

cfg(st).opt.rcnd = '_necker-*.TRC';
cfg(st).opt.trialfun = 'trialfun_necker';

cfg(st).opt.selchan = 1:61;
cfg(st).opt.label = cellfun(@(x) ['E' num2str(x)], num2cell(1:61), 'uni', 0);
%-----------------%

%-----------------%
%-02: gclean
st = st + 1;
cfg(st).function = 'gclean';
cfg(st).step = 'subj';
cfg(st).queue = 'long.q';

cfg(st).opt.fsample = 1024; % <- manually specify the frequency (very easily bug-prone, but it does not read "data" all the time)
cfg(st).opt.hpfreq = [.5 / (cfg(st).opt.fsample/2)]; % normalized by half of the sampling frequency!
cfg(st).opt.bad_channels.MADs = 10;
cfg(st).opt.bad_samples.MADs = 5;
cfg(st).opt.bad_samples.Percentile = [15 85];
cfg(st).opt.eog.correction = 20;
cfg(st).opt.emg.correction = 30;
%-----------------%
%---------------------------%

%---------------------------%
%-INTERVAL ANALYSIS
%-----------------%
%-03: redefine trials
st = st + 1;
cfg(st).function = 'redef';
cfg(st).step = 'subj';
cfg(st).opt.event2trl = 'event2trl_inbetween';

%-------%
%-preproc before
cfg(st).opt.preproc1.hpfilter = 'yes';
cfg(st).opt.preproc1.hpfreq = 0.5;
cfg(st).opt.preproc1.hpfiltord = 4;
%-------%

%-------%
%-preproc after
cfg(st).opt.preproc2.reref = 'yes';
cfg(st).opt.preproc2.refchannel = {'E52' 'E58'}; 
cfg(st).opt.preproc2.implicit = [];
cfg(st).opt.preproc2 = [];
%-------%

%-------%
%-common parameters
cfg(st).opt.redef.trigger = 'switch';
cfg(st).opt.redef.mindist = 1.5; % distance to following switch
cfg(st).opt.redef.maxdist = 60; % distance to following switch
%-------%

%-------%
%-these parameters depend on event2trl_inbetween
cfg(st).opt.redef.pad = 1; % skip the part next to the switch
cfg(st).opt.redef.trldur = 1; % duration of trials TODO: 2s0c
cfg(st).opt.redef.overlap = 0.5; % percentage of overlap between trials
%-------%
%-----------------%

%-----------------%
%-04: power analysis
st = st + 1;
cfg(st).function = 'pow_subj';
cfg(st).step = 'subj';

cfg(st).opt.cond = {'necker-ns*-between' 'necker-sd*-between'};

cfg(st).opt.pow.method = 'mtmfft';
cfg(st).opt.pow.foilim = [2 50];
cfg(st).opt.pow.taper = 'hanning';
%-----------------%

%-----------------%
%-05: pow across subjects
st = st + 1;
cfg(st).function = 'pow_grand';
cfg(st).step = 'grand';

cfg(st).opt.cond = {'necker-ns*-between' 'necker-sd*-between'};
cfg(st).opt.comp = {{'necker-ns*-between'} {'necker-ns*-between' 'necker-sd*-between'}};
cfg(st).opt.numrandomization = 10;
cfg(st).opt.plot.freq(1).name = 'alpha';
cfg(st).opt.plot.freq(1).freq = alphafreq;

cfg(st).opt.plot.chan(1).name = 'occipital';
cfg(st).opt.plot.chan(1).chan = chan;
%-----------------%

%-----------------%
%-06: power correlation analysis
st = st + 1;
cfg(st).function = 'between_into_r';
cfg(st).step = 'subj';

cfg(st).opt.cond = {'necker-ns*-between' 'necker-sd*-between'};
cfg(st).opt.freq = alphafreq;
% cfg(st).opt.powcorr = 3; % XXX: only for backwarks compatibility with previous commit of february
cfg(st).opt.infocol = 3; % 2 -> no log, 3 -> log
cfg(st).opt.channel = chan;
%-----------------%

%-----------------%
%-07: power correlation across subjects
st = st + 1;
cfg(st).function = 'r_grand';
cfg(st).step = 'grand';
cfg(st).opt.rdir = [info.scrp info.nick '_private/rfunctions/'];

cfg(st).opt.rfun(1).name = 'preparedf.R';
cfg(st).opt.rfun(1).args{1} = [info.dcor 'necker--between.csv'];
cfg(st).opt.rfun(1).args{2} = [info.dcor 'durpow_between.Rdata'];

cfg(st).opt.rfun(2).name = 'lmer_dur_pow.R';
cfg(st).opt.rfun(2).args{1} = [info.dcor 'durpow_between.Rdata'];
cfg(st).opt.rfun(2).args{2} = 'pow2';
cfg(st).opt.rfun(2).tolog = true;

cfg(st).opt.rfun(3).name = 'mediation_dur.R';
cfg(st).opt.rfun(3).args = cfg(st).opt.rfun(2).args;
cfg(st).opt.rfun(3).tolog = true;
%-----------------%
%---------------------------%

%---------------------------%
%-EVENT-BASED
%-----------------%
%-08: redefine trials
st = st + 1;
cfg(st).function = 'redef';
cfg(st).step = 'subj';
cfg(st).opt.event2trl = 'event2trl_switch';

%-------%
%-preproc
cfg(st).opt.preproc1 = cfg(3).opt.preproc1;
cfg(st).opt.preproc2 = cfg(3).opt.preproc2;
%-------%

%-------%
%-common parameters
cfg(st).opt.redef.trigger = cfg(3).opt.redef.trigger;
cfg(st).opt.redef.mindist = cfg(3).opt.redef.mindist;
cfg(st).opt.redef.maxdist = cfg(3).opt.redef.maxdist;
%-------%

%-------%
%-these parameters depend on event2trl_switch
cfg(st).opt.redef.prestim = 2; % 2
cfg(st).opt.redef.poststim = 2; % 2
%-------%
%-----------------%

%-----------------%
%-09: power analysis
st = st + 1;
cfg(st).function = 'pow_subj';
cfg(st).step = 'subj';

cfg(st).opt.cond = {'necker-ns*-switch'};

cfg(st).opt.pow.method = 'mtmconvol';
cfg(st).opt.pow.output = 'pow';
cfg(st).opt.pow.taper = 'hanning';
cfg(st).opt.pow.foi = [2:.5:50];
cfg(st).opt.pow.t_ftimwin = 5 ./ cfg(st).opt.pow.foi;
cfg(st).opt.pow.toi = [-1.5:.05:1.5];
%-----------------%

%-----------------%
%-10: pow across subjects
st = st + 1;
cfg(st).function = 'pow_grand';
cfg(st).step = 'grand';

cfg(st).opt.cond = {'necker-ns*-switch'};
cfg(st).opt.comp = {{'necker-ns*-switch'}};
cfg(st).opt.numrandomization = 10;
cfg(st).opt.plot.chan(1).name = 'occ';
cfg(st).opt.plot.chan(1).chan = chan;
%-----------------%

%-----------------%
%-11: power correlation analysis
st = st + 1;
cfg(st).function = 'switch_into_r';
cfg(st).step = 'subj';

cfg(st).opt.cond = {'necker-ns*-switch' 'necker-sd*-switch'};
cfg(st).opt.freq = alphafreq;
cfg(st).opt.time = [0:.05:1];
cfg(st).opt.wndw = .5;
cfg(st).opt.powcorr = 3; % 2 -> no log, 3 -> log
cfg(st).opt.channel = chan;
%-----------------%

%-----------------%
%-12: power correlation across subjects
st = st + 1;
cfg(st).function = 'r_grand';
cfg(st).step = 'grand';
cfg(st).opt.rdir = [info.scrp info.nick '_private/rfunctions/'];

cfg(st).opt.rfun(1).name = 'preparedf.R';
cfg(st).opt.rfun(1).args{1} = [info.dcor 'necker--switch.csv'];
cfg(st).opt.rfun(1).args{2} = [info.dcor 'durpow_switch.Rdata'];

cfg(st).opt.rfun(2).name = 'lmer_predict.R';
cfg(st).opt.rfun(2).args{1} = [info.dcor 'durpow_switch.Rdata'];
cfg(st).opt.rfun(2).args{2} = 'pow2';
cfg(st).opt.rfun(2).tolog = true;
%-----------------%
%---------------------------%

%---------------------------%
%-POWER SOURCE
%-----------------%
%-13: power correlation analysis
st = st + 1;
cfg(st).function = 'source_into_r';
cfg(st).step = 'subj';

cfg(st).opt.cond = {'*necker-ns_001-between', '*necker-ns_002-between' '*necker-ns_003-between' '*necker-ns_004-between' '*necker-ns_005-between'}; % one condition only
cfg(st).opt.freq = mean(alphafreq);
cfg(st).opt.tapsmofrq = diff(alphafreq)/2;
cfg(st).opt.dics.lambda = '5%';
cfg(st).opt.dics.realfilter = 'no';

cfg(st).opt.noise = false; 
cfg(st).opt.log = false;

cfg(st).opt.powcorr = 3; % 2 -> no log, 3 -> log
%-----------------%

%-----------------%
%-14: power correlation analysis
st = st + 1;
cfg(st).function = 'soucorr_r';
cfg(st).step = 'grand';
%-----------------%
%---------------------------%

%---------------------------%
%-DECAY in Alpha Power before the switch
%-----------------%
%-15: redefine trials
st = st + 1;
cfg(st).function = 'redef';
cfg(st).step = 'subj';

cfg(st).opt = cfg(3).opt; % identical options to inbetween, but start from the end
cfg(st).opt.event2trl = 'event2trl_decay';
cfg(st).opt.redef.interval = 'after';
%-----------------%

%-----------------%
%-16: put decay into R
st = st + 1;
cfg(st).function = 'decay_into_r';
cfg(st).step = 'subj';

cfg(st).opt.cond = {'necker-ns*-decay' 'necker-sd*-decay'};
cfg(st).opt.freq = alphafreq;
cfg(st).opt.infocol = 4; 
cfg(st).opt.channel = chan;
%-----------------%

%-----------------%
%-17: average alpha with baseline
st = st + 1;
cfg(st).function = 'decay_to_baseline';
cfg(st).step = 'grand';
cfg(st).opt.csvname = [info.dcor 'necker--decay.csv'];
cfg(st).opt.powtype = 'pow2';
cfg(st).opt.baseline = 'first_epoch'; % [-1.5 -1.5];
cfg(st).opt.baseline_type = 'diff';
cfg(st).opt.grandavg = false;
cfg(st).opt.cond = 'both';
cfg(st).opt.maxdist = -25;
%-----------------%

% %-----------------%
% %-18: alpha decay over time
% st = st + 1;
% cfg(st).function = 'r_grand';
% cfg(st).step = 'grand';
% cfg(st).opt.rdir = [info.scrp info.nick '_private/rfunctions/'];
% 
% cfg(st).opt.rfun(1).name = 'preparedf.R';
% cfg(st).opt.rfun(1).args{1} = [info.dcor 'necker--decay.csv'];
% cfg(st).opt.rfun(1).args{2} = [info.dcor 'durpow_decay.Rdata'];
% 
% cfg(st).opt.rfun(2).name = 'lmer_decay.R';
% cfg(st).opt.rfun(2).args{1} = [info.dcor 'durpow_decay.Rdata'];
% cfg(st).opt.rfun(2).args{2} = cfg(st-1).opt.powtype;
% cfg(st).opt.rfun(2).tolog = true;
% %-----------------%
%---------------------------%

% %---------------------------%
% %-----------------%
% %-18: power correlation analysis
% st = st + 1;
% cfg(st).function = 'switch_into_r';
% cfg(st).step = 'subj';
% 
% cfg(st).opt.cond = {'necker-ns*-switch' 'necker-sd*-switch'};
% cfg(st).opt.freq = alphafreq;
% cfg(st).opt.time = [-.75];
% cfg(st).opt.wndw = .5;
% cfg(st).opt.powcorr = 4; % 2 -> no log, 3 -> log (1 nolog, 4 log, are for the preceding duration)
% cfg(st).opt.channel = chan;
% %-----------------%
% 
% %-----------------%
% %-19: power correlation across subjects
% st = st + 1;
% cfg(st).function = 'r_grand';
% cfg(st).step = 'grand';
% cfg(st).opt.rdir = [info.scrp info.nick '_private/rfunctions/'];
% 
% cfg(st).opt.rfun(1).name = 'preparedf.R';
% cfg(st).opt.rfun(1).args{1} = [info.dcor 'necker--switch.csv'];
% cfg(st).opt.rfun(1).args{2} = [info.dcor 'durpow_switch.Rdata'];
% 
% cfg(st).opt.rfun(2).name = 'lmer_predict.R';
% cfg(st).opt.rfun(2).args{1} = [info.dcor 'durpow_switch.Rdata'];
% cfg(st).opt.rfun(2).args{2} = 'pow2';
% cfg(st).opt.rfun(2).tolog = true;
% %-----------------%
% %---------------------------%

%-----------------%
%-20: export results
st = st + 1;
cfg(st).function = 'exportneckersd';
cfg(st).step = 'summary';
cfg(st).opt.csvf = [info.anly 'neckersd_complete.csv'];
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-EXECUTE
execute(info, cfg)
%-------------------------------------%
