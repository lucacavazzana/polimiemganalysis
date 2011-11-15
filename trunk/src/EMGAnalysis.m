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

%farmData();
recognize();