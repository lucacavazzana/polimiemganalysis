function out = getRaw(EB, w)


if(EB.ser.BytesAvailable)
    out = fscanf(EB.ser, '%c', EB.ser.BytesAvailable);
else
    if(exist('w','var') && w)
        while(~EB.ser.BytesAvailable)
            pause(.001);
        end
        out = fscanf(EB.ser, '%c', EB.ser.BytesAvailable);
    else
        out = [];
    end
end

end