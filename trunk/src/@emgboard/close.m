function status = close(EB)
%CLOSE close serial communication.
%   STATUS = EB.CLOSE() closes the serial port (and any dump file). Returns 1
%   on success.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

fclose(EB.ser);

% close any dump file
if EB.dumpH~=-1
    fclose(EB.dumpH);
end

status = 1;
end