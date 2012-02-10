function status = close(EB)
%

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

fclose(EB.ser);

status = 1;
end