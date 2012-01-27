classdef dummyboard < emgboard
%  extends emg board to simulate emg bursts

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
    
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