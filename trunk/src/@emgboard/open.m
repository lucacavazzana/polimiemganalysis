function status = open(EB, varargin)
%OPEN opens serial port communication.
%   STATUS = OPEN() opens serial port communication (and dump file if
%   specified). Returns 1 on success.
%   If 'log' option is given dumps raw data into 'emgboard.txt'.

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

% dump file
if (EB.dumpH==-1 && ~isempty(EB.dump))
    EB.dumpH = fopen(EB.dump,'w');
end

EB.ser = serial(EB.port);
set(EB.ser, 'BaudRate', 57600);
set(EB.ser, 'InputBufferSize',  4096);  % allows about 1 sec of samples @237Hz (~14char/sample)
set(EB.ser, 'RecordName', 'emgboard.txt');
set(EB.ser, 'RecordDetail', 'verbose');
set(EB.ser, 'Tag', 'EmgBoard');

try
    fopen(EB.ser);
catch e
    instr = instrfind({'Status','Tag'},{'open','EmgBoard'});
    if(~isempty(instr))
        fclose(instr);
        delete(instr);
    end
    fopen(EB.ser);
    % if another exc is thrown, manually handle it...
end

% this is the builtin (less parser-friendly) dump
if LOG
    record(EB.ser, 'on');
end

status = 1;
end