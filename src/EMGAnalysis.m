%% EMGANALYSIS.M
%
% bla bla bla

global port;

%% MY DEBUG VALUES
global DEBUG;
DEBUG = 1;

if DEBUG
    if(ispc())
        port = 'COM3';
    else
        port = 'TTY...';
    end
else
    
    % portGUI
    
end

patient = 'tizioLosco';
gesture = 'mano';

acquireData(paziente, gesture, 0, 1, port);