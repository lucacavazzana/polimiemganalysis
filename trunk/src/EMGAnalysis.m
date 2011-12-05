%EMGANALYSIS
%  bla bla bla.

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
%  FIXME: update

clear all;
clc;

global PORT;
global SERIALCOMM;
global DBG;
DBG = 1;

global LUCA;    % yeah, that's me
LUCA = 1;

if(ispc())
    SERIALCOMM = 'serialComm.exe'; %#ok<NASGU>
else
    SERIALCOMM = './serialComm'; %#ok<NASGU>
end

if LUCA      % FIXME remove here
    if(ispc())
        PORT = 'COM6';
        SERIALCOMM = 'C:\Users\luca\workspace\serialComm\Debug\serialComm.exe'; % FIXME: remove here
    else
        PORT = '/dev/ttyUSB0';
        SERIALCOMM = '/home/luca/workspace/serialComm/Debug/serialComm';
    end
else
    
    PORT = portGUI(); %#ok<UNRCH>
    
end

clc;
sel = input(['What do you wanna do with your life?\n' ...
    '1- acquisition\n' ...
    '2- train whatever\n' ...
    '3- recognize\n' ...
    '4- rec online\n' ...
    '5- test precognition\n', ...
    '6- I wanna rock!\n']);

switch(sel)
    
    case 1
        farmData();
    case 2
        [net perf tr] = trainNN();
    case 3
        recognize();
    case 4
        onlineRecogn();
    case 5
        testPrecog();
    case 6
        web http://www.youtube.com/watch?v=SRwrg0db_zY&t=80 -browser;
    otherwise
        printf('Wrong selection');
end