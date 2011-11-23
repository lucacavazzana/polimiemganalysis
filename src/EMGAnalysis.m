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

if(ispc())
    SERIALCOMM = 'serialComm.exe';
    SERIALCOMM = 'C:\Users\luca\workspace\serialComm\Debug\serialComm.exe'; % FIXME: remove here
else
    SERIALCOMM = './serialComm';
    SERIALCOMM = '/home/luca/work/serialComm/Debug/serialComm'; % FIXME remove here
end

if DEBUG
    if(ispc())
        PORT = 'COM6';
    else
        PORT = 'TTY...';
    end
else
    PORT = portGUI();
    clc;
end

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
else
    printf('Wrong selection');
end