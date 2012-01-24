classdef emgboard < handle
    
    properties
        port;       % port name
        ser;        % serial
        
        chunk;      % incomplete sample from last acquisition
    end     % properties
    
    methods
        
        % constructor
        function EB = emgboard(port)
            
            if(~exist('port','var') || isempty(port))
                if(ispc())
                    EB.port = 'COM6';  % my default port
                else
                    EB.port = '/dev/TTY0';
                end
            else
                EB.port = port;
            end
            
        end
        
        
    end     % methods
    
end     % classdef