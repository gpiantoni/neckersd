function [event] = fixneckerevent(evt, hdr)
%FIXNECKEREVENT

%01 12/02/04 created

distsample = 20; % distance in sample to consider two events overlapping

%-------------------------------------%
%-restructure events
%-----------------%
%-clean evt
%-------%
distevt = find(diff([evt.sample]) <= distsample) + 1; 
if distevt > 0
  fprintf('   overlapping events:% 3.f\n', numel(distevt))
  evt(distevt) = [];
end
%-------%

%-------%
repevt = find(diff([evt.value]) == 0) + 1;
if repevt > 0
  fprintf('   double-press:% 3.f\n', numel(repevt))
  evt(repevt) = [];
end
%-------%
%-----------------%

%-----------------%
%-create events
event = struct('type', [], 'sample', 0, 'value', 0, 'offset', [], 'duration', []);
cnt = 1;
for e = 1:numel(evt)
  switch evt(e).value
    case 102
      event(cnt).type = 'begin';
      event(cnt).sample = evt(e).sample;
      event(cnt).value = -1;
      event(cnt).offset = previousevt(e, evt, hdr);
      event(cnt).duration = nextevt(e, evt, hdr);
      cnt = cnt + 1;
      
    case 103
      event(cnt).type = 'switch';
      event(cnt).sample = evt(e).sample;
      event(cnt).value = 0;
      event(cnt).offset = previousevt(e, evt, hdr);
      event(cnt).duration = nextevt(e, evt, hdr);
      cnt = cnt + 1;
      
    case 104
      event(cnt).type = 'switch';
      event(cnt).sample = evt(e).sample;
      event(cnt).value = 0;
      event(cnt).offset = previousevt(e, evt, hdr);
      event(cnt).duration = nextevt(e, evt, hdr);
      cnt = cnt + 1;
      
    case 105
      event(cnt).type = 'end';
      event(cnt).sample = evt(e).sample;
      event(cnt).value = 1;
      event(cnt).offset = previousevt(e, evt, hdr);
      event(cnt).duration = nextevt(e, evt, hdr);
      cnt = cnt + 1;
      
  end
end
%-----------------%

%-----------------%
%-give feedback
if numel(find([event.value] == -1)) > 1
  fprintf('  ERROR: more than one marker for beginning XXX\n')
  keyboard
end

if event(1).value ~= -1 && numel(find([event.value] == -1)) >= 1
  fprintf('  ERROR: the marker for begin is somewhere else XXX\n')
  keyboard
end

if numel(find([event.value] == 1)) > 1
  fprintf('  ERROR: more than one marker for end XXX\n')
  keyboard
end

if event(end).value ~= 1 && numel(find([event.value] == 1)) >= 1
  fprintf('  ERROR: the marker for end is somewhere else XXX\n')
  keyboard
end
%-----------------%

%-----------------%
%-recreate markers if missing
if event(1).value ~= -1
  newevent.type = 'begin_created';
  newevent.sample = event(1).sample - event(1).offset * hdr.Fs;
  newevent.value = -1;
  newevent.offset = NaN;
  newevent.duration = event(1).offset;
  event = [newevent event];
  fprintf('  warning: creating one marker for beginning\n')
end

if event(end).value ~= 1 
  newevent.type = 'end_created';
  newevent.sample = event(end).sample + event(end).duration * hdr.Fs;
  newevent.value = 1;
  newevent.offset = event(end).duration;
  newevent.duration = NaN;
  event = [event newevent];
  fprintf('  warning: creating one marker for end\n')
end
%-----------------%
%-------------------------------------%

function output = previousevt(e, evt, hdr)
% find how long the event lasts, taking into consideration the end of the
% trial
if e > 1 % good case
  output = (evt(e).sample - evt(e-1).sample) / hdr.Fs;
  if evt(e).value == 102
    fprintf('   previous event is % 3.f for begin\n', evt(e-1).value);
  end
else
  output = (evt(e).sample - 0) / hdr.Fs;

end

function output = nextevt(e, evt, hdr)
% find how long the event lasts, taking into consideration the end of the
% trial
if e < numel(evt) % good case
  output = (evt(e+1).sample - evt(e).sample) / hdr.Fs;
  if evt(e).value == 105
    fprintf('   next event is % 3.f for end\n', evt(e+1).value);
  end
else
  output = (hdr.nSamples - evt(e).sample) / hdr.Fs;
end