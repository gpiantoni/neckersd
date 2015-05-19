function execute(info, cfg)
%EXECUTE the core function, which calls the subfunctions
% 
% Use as:
%   execute(info, cfg)
%
% INFO
%  .sendemail: send email to hard-coded email address (logical)
%  .anly: folder with group analysis
%  .proj: name of the project
%  .qlog: directory with output of SGE
%
% CFG should be a Nx1 struct with obligatory fields:
%  .function: function to call
%  .step: whether the function is subject-specific ('subj') or a
%         grand-average ('grand') or a summary ('summary')
%         In summary, it passes the complete cfg
%  .queue: the queue to send the jobs to (optional)
%  .opt: optional configuration for that function

%-------------------------------------%
%-LOG---------------------------------%
%-------------------------------------%
if ~isfield(info, 'sendemail')
  info.sendemail = true;
end

%-----------------%
%-Log file
logdir = [info.anly 'log/'];
if ~isdir(logdir); mkdir(logdir); end

info.log = sprintf('%slog_%s_%s_%s', ...
  logdir, info.proj, datestr(now, 'yy-mm-dd'), datestr(now, 'HH-MM-SS'));
if ~isdir(info.log); mkdir(info.log); end % logdir for images

fid = fopen([info.log '.txt'], 'w');

output = sprintf('Analysis started at %s on %s\n', ...
  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
fprintf(output)
fwrite(fid, output);
%-----------------%

%-----------------%
%-add toolbox and prepare log
outtool = addtoolbox(info);
output = sprintf('%s\n%s\n%s\n', outtool, struct2log(info), struct2log(cfg));

fwrite(fid, output);
output = regexprep(output, '%', '%%'); % otherwise fprint and fwrite gets confused for normal % sign
fprintf(output)
fclose(fid);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-CALL EACH FUNCTION------------------%
%-------------------------------------%
cd(info.qlog)

%-----------------%
%-transform into cell
infocell = repmat({info}, 1, numel(info.subjall));
subjcell = num2cell(info.subjall);
%-----------------%

for r = info.run
  disp(cfg(r).function)
  cfgcell = repmat({cfg(r).opt}, 1, numel(info.subjall));
  
  %-----------------%
  %-specify queue
  if isfield(cfg(r), 'queue') && ~isempty(cfg(r).queue)
    queue = cfg(r).queue;
  else
    queue = [];
  end
  %-----------------%
  
  switch cfg(r).step
    
    case 'subj'
      %---------------------------%
      %-SINGLE SUBJECT
      %-----------------%
      %-run for all the subjects
      if intersect(r, info.nooge)
        
        %-------%
        for s = info.subjall
          feval(cfg(r).function, info, cfg(r).opt, s);
        end
        %-------%
        
      else
        
        %-------%
        qsubcellfun(cfg(r).function, infocell, cfgcell, subjcell, ...
          'memreq', 8*1024^3, 'timreq', 48*60*60, 'batchid', [info.nick '_' cfg(r).function], 'queue', queue);
        %-------%
        
      end
      %-----------------%
      %---------------------------%
      
    case 'grand'
      %---------------------------%
      %-GROUP
      %-----------------%
      %-run for all the subjects
      if intersect(r, info.nooge)
        
        %-------%
        feval(cfg(r).function, info, cfg(r).opt)
        %-------%
        
      else
        
        %-------%
        qsubcellfun(cfg(r).function, {info}, {cfg(r).opt}, ...
          'memreq', 20*1024^3, 'timreq', 48*60*60, 'backend', 'system', 'queue', queue)
        %-------%
        
      end
      %---------------------------%
      
    case 'summary'
      %---------------------------%
      %-SUMMARY
      %-----------------%
      %-run for all the subjects
      if intersect(r, info.nooge)
        
        %-------%
        feval(cfg(r).function, info, cfg)
        %-------%
        
      else
        
        %-------%
        qsubcellfun(cfg(r).function, {info}, {cfg}, ...
          'memreq', 20*1024^3, 'timreq', 48*60*60, 'backend', 'system', 'queue', queue)
        %-------%
        
      end
      %---------------------------%
      
    otherwise
      warning([cfg(r).step ' can only be ''subj'', ''grand'' or ''summary'''])
      
  end
  
end
%-------------------------------------%

%-------------------------------------%
%-send email
if info.sendemail
  send_email(info)
end
cd(info.scrp)
%-------------------------------------%
