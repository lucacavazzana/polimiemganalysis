classdef emgboard < handle
    %EMGBOARD interface for emg signal acquisition
    %   EMGBOARD(PORT, DUMP) returns an object to handle emg board. PORT is the
    %   serial port name, while DUMP (if provided) is the name of the file
    %   where raw data will be saved (parsable with PARSERAW).
    %
    %   See also CLOSE, GETEMG, GETRAW, OPEN, PARSER, PLOTEMG
    
    %   By Luca Cavazzana for Politecnico di Milano
    %   luca.cavazzana@gmail.com
    
    properties
        port;       	% port name
        ser;            % serial
        
        chunk;          % incomplete sample from last acquisition
        
        dump;
        dumpH = -1;
    end     % properties
    
    properties (Constant)
        sRate = 237;    % serial sample rate.
    end
    
    
    methods
        
        % constructor
        function EB = emgboard(port, dump)
            
            if(nargin == 0 || isempty(port))
                if(ispc())
                    EB.port = 'COM13';  % my default port
                else
                    EB.port = '/dev/TTY0';
                end
            else
                EB.port = port;
            end
            
            if(nargin > 1)
                EB.dump = dump;
            end
            
        end
        
        
    end     % methods
    
    
    
    methods (Static)
        
        function [ch, chunk] = parser(raw, chunk)
            %PARSER parses emg board output
            %   [CH, CHUNK] = PARSER(RAW, CHUNK) parses the emg board
            %   output RAW, concatenating it with CHUNK if provided.
            %   Returns the NxC matrix (with N number of samples, C number
            %   of channels) and the tail of the last incomplete sample.
            
            ds = find(raw == 'D'); % Ds indices
            nSets = 0;
            
            if( nargin>1 && ~isempty(chunk) ) % if chunk is not empty
                
                if(isempty(ds)) % not even a single complete set
                    ch = zeros(0,3);
                    chunk = [chunk, raw];
                    return;
                    
                else
                    ch(size(ds,2),3) = 0;    % preallocate #D
                    chunk = [chunk, raw(1:ds(1))];
                    ch(1,:) = sscanf(chunk(3:end), '%d')';
                    nSets = 1;
                end
                
            end
            
            
            if(length(ds)>1)    % at least a complete sample
                for ii = 2:length(ds)
                    
                    nSets = nSets+1;
                    out = sscanf(raw(ds(ii-1)+2:ds(ii)), '%d')';
                    
                    if (size(out,2)==3)
                        ch(nSets,:) = out;
                        
                    else % FIXME: BUGGED SERIAL BOARD?
                        
                        fprintf(['--------\n' ...
                            'Bad serial output format [%d,%d]\n' ...
                            '%s\n--------\n'], ...
                            ds(ii-1), ds(ii), raw(ds(ii-1):ds(ii)));
                        ch(nSets,:) = ch(nSets-1,:);  % dunno how to manage here... info is lost anyway...
                        warning('Bad serial output format');
                        
                    end
                end     % end for
                
                chunk = raw(ds(end):end);
                
                
            elseif(length(ds) == 1)
                chunk = raw(ds(end):end);
                
            end
            
        end     % parser
        
        
    end     % static methods
end     % classdef