%EMGANALYSIS
%  bla bla bla.
%
% requires fastICA (http://research.ics.tkk.fi/ica/fastica/)

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

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
        SERIALCOMM = 'C:\Users\luca\workspace\serialComm\Debug\serialComm.exe';
    else
        PORT = '/dev/ttyUSB0';
        SERIALCOMM = '/home/luca/workspace/serialComm/Debug/serialComm';
    end
else
    
    % select serial port
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
        [net tr] = trainNN('asd', 10, .5);
    case 3
        recogni2ze();
    case 4
        load('halfNets10.mat', 'net');
        onlineRecognition(net{1});
    case 5
        load('halfNets10.mat');
        testPrecog('asd', net, tr);
    case 6
        web http://www.youtube.com/watch?v=SRwrg0db_zY&t=80 -browser;
    otherwise
        printf('Wrong selection');
end