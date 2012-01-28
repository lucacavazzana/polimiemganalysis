function status = open(EB, varargin)
%

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

EB.ser = serial(EB.port);
set(EB.ser, 'BaudRate', 57600);
set(EB.ser, 'InputBufferSize',  4590);
set(EB.ser, 'RecordName', 'emgboard.txt');
set(EB.ser, 'RecordDetail', 'verbose');
set(EB.ser, 'Tag', 'EmbBoard');

fopen(EB.ser);

if LOG
    record(EB.ser,'on');
end

status = 1;
end