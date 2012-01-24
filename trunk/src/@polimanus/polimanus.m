classdef polimanus < handle
    
    properties
        ser         % serial port handler
        port        % port name
        lastSent    % last sent position
    end     % properties
    
    methods
        
        % constructor
        function PM = polimanus(port)
            if (~exist('port','var') || isempty(port))
                if(ispc())
                    PM.port = 'COM12'; % my default port
                else
                    PM.port = '/dev/TTY...'; % TODO: fill here
                end
            else
                PM.port = port;
            end
        end
        
    end     % functions
    
end