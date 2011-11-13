%EMGANALYSIS
%   bla bla bla.

% By Luca Cavazzana for Politecnico di Milano
% luca.cavazzana@gmail.com
% FIXME: update

global port;

% MY DEBUG VALUES
global DEBUG;
DEBUG = 1;

if DEBUG
    if(ispc())
        port = 'COM3';
    else
        port = 'TTY...';
    end
else
    
    port = portGUI();
    
end

patient = 'tizioLosco';
gesture = 'mano';

acquireData(paziente, gesture, 0, 1, port);