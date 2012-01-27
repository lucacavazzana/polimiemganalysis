function [res] = getPot(PM)
%   get potentiometers' values

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

for ii = 1:5
    while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
        pause(.001);
    end
    fwrite(PM.ser, 251, 'uchar', 'async');
    fwrite(PM.ser, ii, 'uchar', 'async');
    while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
        pause(.001);
    end
    readasync(PM.ser);
    res = fread(PM.ser, 2, 'uchar');
    
    disp(ii);
    disp(res);
end

end