function status = open(EB)
%OPEN opens serial port communication.
%   STATUS = EB.OPEN(varargin) opens serial port communication, returning 1
%   on success.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

% dump file
if (EB.dumpH==-1 && ~isempty(EB.dump))
    EB.dumpH = fopen(EB.dump,'w');
end

EB.ser = serial(EB.port);
set(EB.ser, 'BaudRate', 57600);
set(EB.ser, 'InputBufferSize',  4096);  % allows more than 1s of samples @237Hz (~14char/sample)
set(EB.ser, 'Tag', 'EmgBoard');

try
    fopen(EB.ser);
catch e
    instr = instrfind({'Status','Tag'},{'open','EmgBoard'}); % clears only the ones tagget with "emgboard". Use always this class to manage ERACLE
    if(~isempty(instr))
        fclose(instr);
        delete(instr);
    end
    fopen(EB.ser);
    % if another exc is thrown something is wery wrong, manually handle it...
end

status = 1;
end