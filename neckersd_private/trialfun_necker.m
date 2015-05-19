function [trl, event] = trialfun_necker(cfg)

%-----------------%
% read the header and event information
warning off % creating fake channel names
hdr = ft_read_header(cfg.headerfile);
evt = ft_read_event(cfg.headerfile);
warning on
%-----------------%

[~, filename] = fileparts(cfg.dataset);
fprintf('%s\n', filename);

event = fixneckerevent(evt, hdr);

trl = [event(1).sample+1 event(end).sample 0];