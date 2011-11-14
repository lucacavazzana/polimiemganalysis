%EMGANALYSIS
%   bla bla bla.

% By Luca Cavazzana for Politecnico di Milano
% luca.cavazzana@gmail.com
% FIXME: update

global PORT;

% MY DEBUG VALUES
global DEBUG;
DEBUG = 1;

if DEBUG
    if(ispc())
        PORT = 'COM3';
    else
        PORT = 'TTY...';
    end
else
    
    PORT = portGUI();
    
end

patient = 'tizioLosco';
gesture = 'mano';

acquireData(paziente, gesture, 0, 1, PORT);