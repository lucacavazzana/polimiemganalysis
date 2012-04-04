function moveClose(PM, s)
%MOVECLOSE pPerform close hand movement.
%   PM.MOVECLOSE(S) command hand closing with speed S (within 0 an 255).

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(nargin==1)
    s = 255;
end

PM.move(255, 255, s, s);

end