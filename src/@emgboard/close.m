function status = close(EB)
%CLOSE close serial communication
%   STATUS = CLOSE() closes the serial port (and any dump file). Retruns 1 
%   on success.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

fclose(EB.ser);

if EB.dumpH~=-1
    fclose(EB.dumpH);
end

status = 1;
end