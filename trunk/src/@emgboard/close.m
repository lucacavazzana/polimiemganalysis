function status = close(EB)
%CLOSE close serial communication
%   STATUS = CLOSE() closes the serial port. Retruns 1 if success.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

fclose(EB.ser);

status = 1;
end