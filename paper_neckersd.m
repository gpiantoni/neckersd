% function paper_neckersd

%-----------------------------------------------%
%-MANUSCRIPT------------------------------------%
%-----------------------------------------------%

%-------------------------------------%
%-directories
base_dir = '/PHShome/gp902/';

anly = [base_dir 'projects/neckersd/analysis/'];
dpow = [anly 'pow/'];
dlog = [anly 'log/'];
dcor = [anly 'corr/'];

pdir = [anly 'paper/'];
rmdir(pdir, 's'); 
mkdir(pdir)
%-------------------------------------%

%-------------------------------------%
%-default values
ext = '.pdf';
load([base_dir 'toolbox/elecloc/easycap_61_FT.mat'])
alpha_ns = [7 11];
alpha_sd = [5 11];
plot_freq = [0 30];
plot_time_switch = [-1 1];
chan = {'E25' 'E26' 'E27' 'E28' 'E40' 'E41' 'E42' 'E43' 'E44' 'E53' 'E54' 'E55' 'E56' 'E57'};
%-------------------------------------%

%-------------------------------------%
%-copy data in subjects dir if not present yet
info = info_neckersd;
allsubj = dir([info.recs '00*']);
for i = 1:numel(allsubj)
  data_dir = [info.data allsubj(i).name filesep];
  mkdir(data_dir)
  eeg_dir = [data_dir 'eeg' filesep];
  mkdir(eeg_dir)
  eeg_dir = [data_dir 'neckersd' filesep];
  mkdir(eeg_dir)
  
  copyfile([info.recs allsubj(i).name filesep 'eeg' filesep 'raw' filesep '*.mat'], ...
           eeg_dir)
  fileattrib([eeg_dir '*.mat'], '+w', 'u')
end
%-------------------------------------%

%-------------------------------------%
%-run on normal sleep
cfgin.run = 3:13;
cfgin.chan = chan;
cfgin.alphafreq = alpha_ns;
neckersd(cfgin)
%-------------------------------------%

%-------------------------------------%
%-get latest log
dirlog = dir(dlog);
dirlog = dirlog([dirlog.isdir]);
dirlog = dirlog(3:end); % exclude . and ..
[~, imax] = max([dirlog.datenum]);
logname = dirlog(imax).name;
%-------------------------------------%

%-------------------------------------%
%-FIGURE: neckersd_powns
load([dpow 'pow_necker-ns-between.mat'], 'pow')
pow.dimord = 'chan_freq';

%---------------------------%
%-A. power spectrum
h = figure('vis', 'off');

cfg = [];
cfg.ylim = [0 1] * 1000;
cfg.xlim = plot_freq;
cfg.channel = chan;
ft_singleplotER(cfg, pow);
hold on
plot(alpha_ns([1 1]), cfg.ylim, 'r')
plot(alpha_ns([2 2]), cfg.ylim, 'r')

saveas(h, [pdir 'neckersd_powns_A' ext])
delete(h)
%---------------------------%

%---------------------------%
%-B. topoplot
h = figure('vis', 'off');
cfg = [];
cfg.layout = layout;
cfg.xlim = alpha_ns;
cfg.zlim = [0 1] * 650;
cfg.style = 'straight';

cfg.highlight = 'on';
cfg.highlightchannel = chan;
cfg.highlightsymbol = '.';

ft_topoplotER(cfg, pow);
saveas(h, [pdir 'neckersd_powns_B' ext])
delete(h)
%---------------------------%

%---------------------------%
%-C. event-related alpha
h = figure('vis', 'off');
load([dpow 'pow_necker-ns-switch.mat'], 'pow')
cfg =[];
cfg.channel = chan;
cfg.xlim = plot_time_switch;
cfg.ylim = plot_freq;
cfg.zlim = [0 1] * 900;
ft_singleplotTFR(cfg, pow);
set(gca, 'xtick', [], 'ytick', [])
title('')
colorbar off
saveas(h, [pdir 'neckersd_powns_C' '.tiff'])
delete(h)
%---------------------------%

%---------------------------%
%-D. 
h = figure('vis', 'off');
csvfile = [dlog logname '/predict_values.csv'];
predict_values = dlmread(csvfile);

predict_time = 0:.05:plot_time_switch(2);
plot(predict_time, predict_values(1:numel(predict_time)))
hold on
plot([0 1], [1 1] * 1.96, 'r')
plot([0 1], [0 0], 'r')
ylim([-2 4])
saveas(h, [pdir 'neckersd_powns_D' ext])
delete(h)
%---------------------------%
%-------------------------------------%

%-------------------------------------%
%-FIGURE: decay
%---------------------------%
%-read data
csvfile = [dlog logname '/alpha_decay.csv'];
decay = dlmread(csvfile);
decay = decay(:, 1:end-1);  % remove last line

all_dist = decay(1, :);
m = decay(2, :);
sem = decay(3, :);
n = decay(4, :);
%---------------------------%

%---------------------------%
%-make figure
x = all_dist(all_dist >= max_dist);
y = m(all_dist >= max_dist);
max_dist = -25;
h = figure('vis', 'on');
hold on
plot(x, y, '.-')
% p = polyfit(x, y, 1);
% r = p(1) .* x + p(2);
% plot(x, r, '-');
saveas(h, [pdir 'alpha_decay' ext]);
delete(h)
%---------------------------%

%---------------------------%
%-calculate R-value
sel_dur = all_dist(all_dist >= max_dist); 
sel_m = m(all_dist >= max_dist);
[r, p] = corr(sel_dur', sel_m');
fprintf('correlation R=%0.4f, p=%0.3f\n', r, p);
%---------------------------%
%-------------------------------------%

%-------------------------------------%
%-FIGURE: neckersd_soucorr
%---------------------------%
%-read data
csvsoucorr = [dlog logname '/soucorr.csv'];
% csvsoucorr = '/data1/projects/neckersd/results/121008_soucorr.csv'; 
fid = fopen(csvsoucorr, 'r');

C = textscan(fid, '%n %n');
fclose(fid);
%---------------------------%

%---------------------------%
%-create source
load([anly 'smri/vigd_volleadsens_spmtemplate_dipoli.mat'], 'lead')
source = [];
source.pos = lead.pos;
source.inside = lead.inside;
source.outside = lead.outside;
source.dim = lead.dim;

source.pow = NaN(1, size(source.pos,1));
source.pow(C{1}) = C{2};

source.mask = .3*ones(size(source.pow));
source.mask(source.pow > tinv(1-0.01, 1e6)) = 1;  % 1e6 is good enough, but higher makes it wrong!
%---------------------------%

%---------------------------%
%-interpolate
mri = ft_read_mri([anly 'smri/neckersd_vigd_avg_smri_t1_spm.nii.gz']);
tmpcfg = [];
tmpcfg.parameter = {'pow' 'mask'};
souint = ft_sourceinterpolate(tmpcfg, source, mri);
%---------------------------%

%---------------------------%
%-plot source
filename = [pdir 'sources'];
format = '-dtiff';
res = '-r150';

figure
tmpcfg = [];
tmpcfg.funparameter = 'pow';
tmpcfg.maskparameter = 'mask';

tmpcfg.method = 'surface';
tmpcfg.camlight = 'no';

tmpcfg.projmethod = 'nearest';
% tmpcfg.projmethod = 'sphere_avg';
tmpcfg.sphereradius = 5;

tmpcfg.surffile = [base_dir 'toolbox/fieldtrip/template/anatomy/surface_wm_left.mat'];
tmpcfg.surfdownsample = 10;
ft_sourceplot(tmpcfg, souint);

view(-60, 10)
h = camlight('right');
print(gcf, [filename '_lh_left'], format, res)

view(60, 10)
camlight(h, 'left');
print(gcf, [filename '_lh_right'], format, res)

delete(gcf)

figure
tmpcfg.surffile = [base_dir 'toolbox/fieldtrip/template/anatomy/surface_wm_right.mat'];
ft_sourceplot(tmpcfg, souint);

view(-60, 10)
h = camlight('left');
print(gcf, [filename '_rh_left'], format, res)

view(60, 10)
camlight(h, 'right');
print(gcf, [filename '_rh_right'], format, res)
%---------------------------%
%-------------------------------------%

%-------------------------------------%
%-run on sleep deprivation
%---------------------------%
%-A. power spectrum
h = figure('vis', 'off');
cfg = [];
cfg.ylim = [0 1] * 1000;
cfg.xlim = plot_freq;
cfg.channel = chan;
load([dpow 'pow_necker-ns-between.mat'], 'pow')
pow.dimord = 'chan_freq';
pow1 = pow;
load([dpow 'pow_necker-sd-between.mat'], 'pow')
pow.dimord = 'chan_freq';
ft_singleplotER(cfg, pow1, pow);
hold on
plot(alpha_sd([1 1]), cfg.ylim, 'r')
plot(alpha_sd([2 2]), cfg.ylim, 'r')

saveas(h, [pdir 'neckersd_pownssd_A' ext])
%---------------------------%
%-------------------------------------%
