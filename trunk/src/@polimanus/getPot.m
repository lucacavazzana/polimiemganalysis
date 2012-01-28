function [res] = getPot(PM)
%   get potentiometers' values

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
    pause(.001);
end
fwrite(PM.ser, 250, 'uchar', 'async');
while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
    pause(.001);
end
readasync(PM.ser);
res = fread(PM.ser, 4, 'uchar');

return

for ii = 1:20
    while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
        pause(.001);
    end
    fwrite(PM.ser, [251, ii], 'uchar', 'async');
    while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
        pause(.001);
    end
    readasync(PM.ser);
    res{ii} = fread(PM.ser, 2, 'uchar');
    
end

end