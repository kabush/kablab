function [success] = logger(str,log_file)
% LOGGER logs the string on a unique line of the log_file
%
%  [success] = logger(str,log_file)
%
%  ARGUMENTS
%    str = the string to be logged
%    log_file = the path to where logs will be kept
%
%  OUTPUTS
%    success = binary [0,1] indicating whether the log was successful
%
%  REFERENCES

success=0;

% echo the string
disp(str);

% log the string
str=[str,'\r\n'];
try
    file_obj=fopen(log_file,'a');
    fprintf(file_obj,str);
    fclose(file_obj);
    success=1;
catch
    % do nothing
end
