classdef dummyboard < emgboard
%DUMMYBOARD extends emg board to simulate emg bursts
%   DUMMYBOARD(SRC) returns an object which simulates an serial emg board.
%   It will output random noise to simulate muscle ianctive state, and
%   pre-recorded signals when selected from the interface. Pre recorded
%   signals are stored into a .mat file whose path is specified by SRC.
%
%   See also CLOSE, DUMMYBOARDGUI, GETEMG, OPEN, PLOTEMG

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com
    
    properties
        emgs;
        targets;
        
        move;               % current gesture
        gTime;              % gesture starting time
        
        last = 0;           % time first acq
        burst = 0;          % training burst selection
        iBurst = 0;         % index of the last outputted chunk
    end     % properties
    
    methods
        
        % constructor
        function DB = dummyboard(src)
            
            if(exist('src','var'))
                DB.port = src;
            else
                DB.port = 'emgsA.mat';  % MA QUESTI SONO GIà FILTRATI!
            end
        end
        
        
    end     % methods
    
    
end