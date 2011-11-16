%EMGANALYSIS
%	bla bla bla.

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com
%	FIXME: update

clear all;
clc;

global PORT;
global SERIALCOMM;
global DEBUG;   % comment out here
DEBUG = 1;

if(ispc())
    SERIALCOMM = 'serialComm.exe';
else
    SERIALCOMM = './serialComm';
end


if exist('DEBUG','var')
    if(ispc())
        PORT = 'COM3';
    else
        PORT = 'TTY...';
    end
    if(ispc())
        SERIALCOMM = 'C:\Users\luca\workspace\serialComm\Debug\serialComm.exe';
    else
        SERIALCOMM = '/home/luca/work/serialComm\Debug\serialComm';
    end
else
    
    PORT = portGUI();
    
end

sel = input(['What do you wanna do with your life?\n' ...
    '1- acquisition\n' ...
    '2- train whatever\n' ...
    '3- I wanna rock!\n']);

if(sel == 1)
    farmData();
elseif(sel == 2)
    disp('Working on it');
elseif(sel == 3)
    recognize();
else
    printf('Wrong selection');
end