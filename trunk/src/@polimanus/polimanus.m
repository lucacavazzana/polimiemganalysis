classdef polimanus < handle
    %POLIMANUS class to handle Polimanus exoskeleton
    % 
    %   This class handles serial communication with Polimanus
    %   exoskeleton, providing high-level methods to control it.
    %
    %   NOTE: You may wanna download drivers from FTDI website
    %   (http://www.ftdichip.com/Drivers/VCP.htm).
    %
    %   See also CHANGEPORT, CLOSE, MOVE, MOVECLOSE, MOVEOPEN, MOVEPINCH,
    %   OPEN
    
    %   By Luca Cavazzana for Politecnico di Milano
    %   luca.cavazzana@gmail.com
    
    properties
        ser         % serial port handler
        port        % port name
        lastSent    % last sent position
    end     % properties
    
    methods
        function PM = polimanus(port)
            % POLIMANUS constructor of the class polimanus.
            %   PM = POLIMANUS(PORT) creates an handler for the Polimanus 
            %   exoskeleton on port PORT
            
            if (~exist('port','var') || isempty(port))
                if(ispc())
                    PM.port = 'COM12'; % my default port
                else
                    PM.port = '/dev/ttyUSB1...'; % TODO: fill here
                end
            else
                PM.port = port;
            end
        end
        
    end     % functions
    
end