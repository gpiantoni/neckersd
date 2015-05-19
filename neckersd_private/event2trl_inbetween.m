function [cond output] = event2trl_inbetween(cfg, event)
%EVENT2TRL_INBETWEEN create trials for welch's analysis 
% Use as:
%   [cond output] = event2trl_inbetween(cfg, event)
% where
%   cfg is cfg.redef
%   cfg.redef.trigger = 'switch';
%   cfg.redef.mindist = 1; % distance to following switch
%   cfg.redef.maxdist = 60; % distance to following switch
%   cfg.redef.pad     = 0.5; % skip the part next to the switch
%   cfg.redef.trldur  = 1; % duration of trials
%   cfg.redef.overlap = 0.5; % percentage of overlap between trials
% 
%   cond is a struct with
%     .name = 'between'
%     .trl = [begsmp endsmp offset];
%     .trialinfo = extra_trialinfo (optional)
%   output is a text for output
%
% Part of NECKERSD_PRIVATE
% see also EVENT2TRL_NECKER, EVENT2TRL_BOTH

%-----------------%
%-create trl where there is a switch
mrk = find(strcmp({event.type}, cfg.trigger));

mrkbnd = [[event(mrk).sample]' [event(mrk+1).sample]'];
inbetween = [event(mrk).duration]';

%-------%
%-avoid data just around the switch
mrkbnd(:,1) = mrkbnd(:,1) + cfg.fsample * cfg.pad;
mrkbnd(:,2) = mrkbnd(:,2) - cfg.fsample * cfg.pad - 1;
%-------%

%-------%
%-create smaller trials
begdist = cfg.overlap * cfg.trldur * cfg.fsample; % distance in samples between smaller trials
trl = [];
grouping = [];
for i = 1:size(mrkbnd,1)
  trlbeg = [mrkbnd(i,1): begdist:mrkbnd(i,2)]';
  trlnew = [trlbeg trlbeg+cfg.trldur*cfg.fsample-1];
  trlnew = trlnew(trlnew(:,2) <= mrkbnd(i,2), :); % only trials that end before the marker
  trl = [trl; trlnew];
  grouping = [grouping; ones(size(trlnew,1),1) * i];
end
%-------%

info = [grouping inbetween(grouping)]; 
info(:,3) = log(info(:,2));
%-----------------%

%-----------------%
%-only keep switch if it's not too close to previous or following switch
enoughdist = all(info(:,2) > cfg.mindist, 2) & all(info(:,2) < cfg.maxdist,2);

cond(1).name = 'between';
cond(1).trl = [trl(enoughdist,:) ones(numel(find(enoughdist)),1)];
cond(1).trialinfo = info(enoughdist,:);
%-----------------%

%-----------------%
%-output
output = sprintf('   n events:% 4d (total switch:% 4d at mindist% 4.2fs, maxdist% 4.2fs)\n', ...
  numel(find(enoughdist)), numel(mrk), min(cond(1).trialinfo(:,2)), max(cond(1).trialinfo(:,2)));
%-----------------%
