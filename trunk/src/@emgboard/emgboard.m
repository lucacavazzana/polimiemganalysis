classdef emgboard < handle
%

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
    
    properties
        port;       	% port name
        ser;            % serial
        
        chunk;          % incomplete sample from last acquisition
    end     % properties
    
    properties (Constant)
        sRate = 240;    % serial sample rate
    end
    
    
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