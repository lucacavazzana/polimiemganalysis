function status = open(PM, varargin)
%   open serial port

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

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

fopen(PM.ser);

if LOG
    record(PM.ser,'on');
end

status = 0;
end