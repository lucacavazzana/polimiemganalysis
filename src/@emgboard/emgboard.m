classdef emgboard < handle
    %EMGBOARD interface for emg signal acquisition
    %   EMGBOARD(PORT, DUMP) returns an object to handle emg board. PORT is the
    %   serial port name, while DUMP (if provided) is the name of the file
    %   where raw data will be saved.
    %
    %   See also CLOSE, GETEMG, GETRAW, OPEN, PLOTEMG
    
    %   By Luca Cavazzana for Politecnico di Milano
    %   luca.cavazzana@gmail.com
    
    properties
        port;       	% port name
        ser;            % serial
        
        chunk;          % incomplete sample from last acquisition
        
        dumpName;
        dump = -1;
    end     % properties
    
    properties (Constant)
        sRate = 237;    % serial sample rate.
    end
    
    
    methods
        
        % constructor
        function EB = emgboard(port, dump)
            
            if(nargin == 0 || isempty(port))
                if(ispc())
                    EB.port = 'COM6';  % my default port
                else
                    EB.port = '/dev/TTY0';
                end
            else
                EB.port = port;
            end
            
            if(nargin > 1)
                EB.dumpName = dump;
                EB.dump = fopen(dump,'w');
            end
            
        end
        
        
    end     % methods
    
end     % classdef