classdef dummyboard < emgboard
    %DUMMYBOARD extends emg board to simulate emg bursts
    %
    %   This object will simulate the output of an EMG board outputting
    %   random noise to simulate muscle inactive state, and pre-recorded
    %   signals when selected from the interface.
    %
    %   See also CLOSE, DUMMYBOARDGUI, GETEMG, OPEN, PLOTEMG
    
    %   By Luca Cavazzana for Politecnico di Milano
    %   luca.cavazzana@gmail.com
    
    properties
        emgs;               % pre-recorded bursts
        targets;            % movement id of the pre-recorded bursts
        
        move;               % current gesture
        
        last = 0;           % time latest acquisition
        burst = 0;          % selected burst
        iBurst = 0;         % index of the last outputted sample
    end     % properties
    
    methods
        
        % constructor
        function DB = dummyboard(src)
            %DUMMYOBARD class constructor
            %
            %   DB = DUMMYBOARD(SRC) returns an object which simulates a
            %   serial emg board. SRC contains the path of the .mat file
            %   where pre-recorded signals are stored
            
            if(exist('src','var'))
                DB.port = src;
            else
                DB.port = 'tmp/emgsA.mat'; %default file
            end
        end
        
    end     % methods
    
end