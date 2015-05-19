function soucorr_r(info, opt)
%SOUCORR_R correlation of the source in R
% 

%---------------------------%
%-start log
output = sprintf('%s started at %s on %s\n', ...
  mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
% correlation for each source point
rdir = [info.scrp info.nick '_private/rfunctions/'];
funname = [rdir 'lmer_source.R'];
args = [info.dcor ' ' info.log filesep];
MatlabPath = getenv('LD_LIBRARY_PATH');
setenv('LD_LIBRARY_PATH', getenv('PATH'))
system(['Rscript ' funname ' ' args]);
setenv('LD_LIBRARY_PATH', MatlabPath)
%---------------------------%

%---------------------------%
%-read data
fid = fopen([info.log filesep 'soucorr.csv'], 'r');
C = textscan(fid, '%n %n');
fclose(fid);
%---------------------------%

%---------------------------%
%-create source
load(info.vol.template, 'lead')
source = [];
source.pos = lead.pos;
source.inside = lead.inside;
source.outside = lead.outside;
source.dim = lead.dim;
source.pow = NaN(1, size(source.pos,1));
source.pow(C{1}) = C{2};
%---------------------------%

%---------------------------%
%-interpolate
mri = ft_read_mri([info.anly 'smri/neckersd_vigd_avg_smri_t1_spm.nii.gz']);
tmpcfg = [];
tmpcfg.parameter = {'pow'};
source = ft_sourceinterpolate(tmpcfg, source, mri);
%---------------------------%

%---------------------------%
%-plot source
tmpcfg = [];
tmpcfg.funparameter = 'pow';
tmpcfg.method = 'slice';
ft_sourceplot(tmpcfg, source);

%--------%
%-save and link
pngname = 'lmer_source';
saveas(gcf, [info.log filesep pngname '.png'])
close(gcf); drawnow

[~, logfile] = fileparts(info.log);
system(['ln ' info.log filesep pngname '.png ' info.rslt pngname '_' logfile '.png']);
%--------%
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
fid = fopen([info.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%