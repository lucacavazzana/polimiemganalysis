%EMGANALYSIS
%   START FROM HERE!
%   launches the starting menu
%
%   requires fastICA (http://research.ics.tkk.fi/ica/fastica/)

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

clear all;
close all;
fclose all;
clc;

% global PORT;
% global SERIALCOMM;
% global DBG;
% DBG = 1;

global LUCA;    % yeah, that's me. Debug
LUCA = 1;

% --- OLD CODE, LEGACY OF THE OLD serialComm.c ---
% if(ispc())
%     SERIALCOMM = 'serialComm.exe'; %#ok<NASGU>
% else
%     SERIALCOMM = './serialComm'; %#ok<NASGU>
% end
% 
% if LUCA      % FIXME remove here
%     if(ispc())
%         PORT = 'COM6';
%         SERIALCOMM = 'C:/Users/luca/workspace/serialComm/Debug/serialComm.exe';
%     else
%         PORT = '/dev/ttyUSB0';
%         SERIALCOMM = '/home/luca/workspace/serialComm/Debug/serialComm';
%     end
% else
%     
%     % select serial port
%     PORT = portGUI(); %#ok<UNRCH>
%     
% end
% --- ---

clc;
sel = input(['What do you wanna do with your life?\n' ...
    '1- acquisition\n' ...
    '2- train nets\n' ...
    '3- test net\n' ...
    '4- rec online\n' ...
    '5- test precognition\n', ...
    '6- I wanna rock!\n']);


folder = 'lucaPM';

switch(sel)
    case 1  % acquire new training set
        farmData();
        
    case 2  % train new NNs for classification
        [nets trs] = trainNN(folder, 2, 1);
        
    case 3  % remove this one...
        load(sprintf('%s/net.mat', folder),'nets');
        testNet(nets{1});
        
    case 4  % online classification
        load(sprintf('%s/net.mat', folder),'nets');
        onlineRecognition(nets{1}, 'plot');
        
    case 5  % test recognition rate 
        load(sprintf('%s/net.mat', folder),'nets');
        testPrecog('asd', nets{1}, trs);
        
    case 6
        web http://www.youtube.com/watch?v=SRwrg0db_zY&t=80 -browser;
        
    otherwise
        printf('Wrong selection');
end