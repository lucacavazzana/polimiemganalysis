function close(PM)
%CLOSE close serial communication.
%   PM.CLOSE() closes the serial port communication.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if (strcmp(PM.ser.TransferStatus, 'idle') == 0)
    stopasync(PM.ser);
end

fclose(PM.ser);
end