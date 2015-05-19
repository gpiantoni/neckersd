%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEND EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function send_email(info)

% 11/01/27 with pdf attachments
% 11/01/18 adapted from meg_sleep, now uses info instead of loading file

output = sprintf('Analysis ended at %s on %s\n', ...
  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
fprintf(output)

fid = fopen([info.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read log file
fid = fopen([info.log '.txt'], 'r');
mailtext = textscan(fid, '%s', 'whitespace' , '', 'BufSize', 1e6);
fclose(fid);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % find attachments
pngfind  = dir([info.log filesep '*.p*']);
attachment = [];
cnt = 0;
for k=1:numel(pngfind)
  cnt = cnt + 1;
   attachment{cnt} = [info.log filesep pngfind(k).name];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send the email
if isempty(attachment)
  send_mail_message('gpiantoni+overnightscript', [info.proj '/' info.nick], mailtext)
else
  send_mail_message('gpiantoni+overnightscript', [info.proj '/' info.nick], mailtext, attachment)
end
