function status = open(PM, varargin)
%OPEN open serial communication.
%   STATUS = PM.OPEN(varargin) opens serial port communication, returning
%   success status. If the string log is within the optional arguments the
%   serial communication is dumped on disk.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

LOG = 0;
if(~isempty(varargin))
    for inp = varargin
        if(strcmp(inp,'log'))
            LOG = 1;
        end
    end
end

PM.ser = serial(PM.port);
set(PM.ser, 'BaudRate', 115200);
set(PM.ser, 'Terminator', 'LF');
set(PM.ser, 'InputBufferSize', 10000);
set(PM.ser, 'timeout', 0.5);
set(PM.ser, 'RecordName', 'polimanus.txt');
set(PM.ser, 'RecordDetail', 'verbose');
set(PM.ser, 'Tag', 'Polimanus');

try
    fopen(PM.ser);
    
catch e
    instr = instrfind({'Status','Tag'},{'open','Polimanus'});
    if(~isempty(instr))
        fclose(instr);
        delete(instr);
    end
    fopen(PM.ser);
    % if another exc is thrown, manually handle it...
end

if LOG
    record(PM.ser,'on');
end

status = 1;
end