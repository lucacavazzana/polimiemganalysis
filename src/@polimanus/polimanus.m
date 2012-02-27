classdef polimanus < handle
%POLIMANUS class to handle Polimanus exoskeleton
%   POLIMANUS(PORT) creates an handler for the Polimanus exoskeleton on
%   port PORT.
%   NOTE: You may wanna download drivers from FTDI website
%   (http://www.ftdichip.com/Drivers/VCP.htm).
%
%   See also CHANGEPORT, CLOSE, MOVE, MOVECLOSE, MOVEOPEN, MOVEPINCH, OPEN

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

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