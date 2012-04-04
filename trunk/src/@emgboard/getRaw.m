function out = getRaw(EB, w)
%GETRAW get raw data input from serial port.
%
%   RAW = EB.GETRAW(W) returns the raw output from the serial board. If W
%   is specified and not zero this call will be blocking.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(EB.ser.BytesAvailable)
    out = fscanf(EB.ser, '%c', EB.ser.BytesAvailable);
else
    % if WAIT flag
    if( nargin>1 && w )
        while(EB.ser.BytesAvailable == 0)
            pause(.001);
        end
        out = fscanf(EB.ser, '%c', EB.ser.BytesAvailable);
    else
        out = [];
    end
end

end