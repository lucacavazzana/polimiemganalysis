%EMGANALYSIS
%	bla bla bla.

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com
%	FIXME: update

clear all;
clc;

global PORT;
global SERIALCOMM;
global DEBUG;
DEBUG = 1;

global LUCA;    % yeah, that's me
LUCA = 1;

if(ispc())
    SERIALCOMM = 'serialComm.exe';
else
    SERIALCOMM = './serialComm';
end

if LUCA      % FIXME remove here
    if(ispc())
        PORT = 'COM6';
        SERIALCOMM = 'C:\Users\luca\workspace\serialComm\Debug\serialComm.exe'; % FIXME: remove here
    else
        PORT = 'TTY...';
        SERIALCOMM = '/home/luca/work/serialComm/Debug/serialComm';
    end
else
    
    PORT = portGUI();
    
end

clc;
sel = input(['What do you wanna do with your life?\n' ...
    '1- acquisition\n' ...
    '2- train whatever\n' ...
    '3- recognize\n' ...
    '4- I wanna rock!\n']);

if(sel == 1)
    farmData();
elseif(sel == 2)
    disp('Working on it');
elseif(sel == 3)
    recognize();
elseif(sel == 4)
    web http://www.youtube.com/watch?v=SRwrg0db_zY&t=80 -browser;
else
    printf('Wrong selection');
end