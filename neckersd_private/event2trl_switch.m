function [cond output] = event2trl_switch(cfg, event)
%EVENT2TRL_SWITCH create four types of trials based on stim and resp
% Use as:
%   [cond output] = event2trl_trial(cfg, event)
% where
%   cfg is cfg.redef
%   cfg.redef.trigger = 'switch'
%   cfg.redef.prestim: one scalar, time before switch
%   cfg.redef.poststim: one scalar, time after switch
%   
%   cond is a struct with
%     .name = 'switch'
%     .trl = [begsmp endsmp offset];
%     .trialinfo = extra_trialinfo (optional)
%   output is a text for output
%
% trialinfo:
%  - time from previous reversak (s)
%  - time to following reversal (s)
%  - time to following reversal (log(s))
%  - time from previous reversak (log(s)) NOT INTUITIVE, SORRY, TO KEEP PREVIOUS CODE
% 
% Part of NECKERSD_PRIVATE
% see also EVENT2TRL_INBETWEEN, EVENT2TRL_BOTH

%-----------------%
%-create trl where there is a switch
mrk = find(strcmp({event.type}, cfg.trigger));

trl = [[event(mrk).sample] - cfg.prestim * cfg.fsample; ...
  [event(mrk).sample] + cfg.poststim * cfg.fsample - 1; ...
  -cfg.prestim * cfg.fsample * ones(1,numel(mrk))]';

info = [[event(mrk).offset]' [event(mrk).duration]']; % there are the same but switch by one place
info(:,3) = log(info(:,2));
info(:,4) = log(info(:,1));
%-----------------%

%-----------------%
%-only keep switch if it's not too close to previous or following switch
enoughdist = all(info(:,1:2) > cfg.mindist, 2) & all(info(:,2) < cfg.maxdist,2);

cond(1).name = 'switch';
cond(1).trl = trl(enoughdist,:);
cond(1).trialinfo = info(enoughdist,:);
%-----------------%

%-----------------%
%-output
output = sprintf('   n events:% 4d (total switch:% 4d at mindist% 4.2fs, maxdist% 4.2fs)\n', ...
  numel(find(enoughdist)), numel(mrk), min(info(:,2)), max(info(:,2)));
%-----------------%
