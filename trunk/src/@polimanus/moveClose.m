function moveClose(PM, s)
%MOVECLOSE perform close hand movement
%   MOVECLOSE(S) commands hand closing at speed S (within 0 an 255).

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if ~exist('s','var')
    s = 255;
end

PM.move(255, 255, s, s);

end