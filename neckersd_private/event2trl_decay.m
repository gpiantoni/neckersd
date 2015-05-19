function [cond output] = event2trl_decay(cfg, event)
%EVENT2TRL_DECAY create trials and count starting from the end
% Use as:
%   [cond output] = event2trl_decay(cfg, event)
% where
%   cfg is cfg.redef
%   cfg.redef.trigger = 'switch';
%   cfg.redef.interval = 'before' or 'after'; % specify which interval to
%     use, before or after the switches (default: 'after')
%   cfg.redef.mindist = 1; % distance to following switch
%   cfg.redef.maxdist = 60; % distance to following switch
%   cfg.redef.pad     = 0.5; % skip the part next to the switch
%   cfg.redef.trldur  = 1; % duration of trials
%   cfg.redef.overlap = 0.5; % percentage of overlap between trials
% 
%   cond is a struct with
%     .name = 'decay'
%     .trl = [begsmp endsmp offset];
%     .trialinfo = extra_trialinfo (optional)
%   output is a text for output
%
% Part of NECKERSD_PRIVATE
% see also EVENT2TRL_INBETWEEN, EVENT2TRL_SWITCH

%-----------------%
%-create trl where there is a switch
mrk = find(strcmp({event.type}, cfg.trigger));

if ~isfield(cfg, 'interval') || strcmp(cfg.interval, 'after')
  mrkbnd_orig = [[event(mrk).sample]' [event(mrk+1).sample]'];
  inbetween = [event(mrk).duration]';
else
  mrkbnd_orig = [[event(mrk-1).sample]' [event(mrk).sample]'];
  inbetween = [event(mrk).offset]';
end

%-------%
%-avoid data just around the switch
mrkbnd(:,1) = mrkbnd_orig(:,1) + cfg.fsample * cfg.pad;
mrkbnd(:,2) = mrkbnd_orig(:,2) - cfg.fsample * cfg.pad - 1;
%-------%

%-------%
%-create smaller trials
begdist = cfg.overlap * cfg.trldur * cfg.fsample; % distance in samples between smaller trials
trl = [];
grouping = [];
dist_end = [];

correction_factor = 1.5; % difference in samples between the ideal and our computation
for i = 1:size(mrkbnd,1)
  
  %-start from the end (instead of inbetween)
  trlbeg = [mrkbnd(i,2): -begdist:mrkbnd(i,1)]';
  trlbeg = sort(trlbeg);
  
  trlnew = [trlbeg trlbeg+cfg.trldur*cfg.fsample-1];
  trlnew = trlnew(trlnew(:,2) <= mrkbnd(i,2), :); % only trials that end before the marker
  trl = [trl; trlnew];
  grouping = [grouping; ones(size(trlnew,1),1) * i];
  dist_end = [dist_end; (mrkbnd_orig(i,2) - mean(trlnew,2) - correction_factor) / cfg.fsample];
end
%-------%

info = [grouping inbetween(grouping)]; 
info(:,3) = log(info(:,2));
info(:,4) = dist_end;
%-----------------%

%-----------------%
%-only keep switch if it's not too close to previous or following switch
enoughdist = all(info(:,2) > cfg.mindist, 2) & all(info(:,2) < cfg.maxdist,2);

cond(1).name = 'decay';
cond(1).trl = [trl(enoughdist,:) ones(numel(find(enoughdist)),1)];
cond(1).trialinfo = info(enoughdist,:);
%-----------------%

%-----------------%
%-output
output = sprintf('   n events:% 4d (total switch:% 4d at mindist% 4.2fs, maxdist% 4.2fs)\n', ...
  numel(find(enoughdist)), numel(mrk), min(cond(1).trialinfo(:,2)), max(cond(1).trialinfo(:,2)));
%-----------------%
