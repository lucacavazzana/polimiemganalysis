function moveOpen(PM, s)
%MOVEOPEN perform open hand movement.
%   PM.MOVEOPEN(S) commands hand opening at speed S (within 0 an 255).

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(nargin==1)
    s = 255;
end

PM.move(1, 1, s, s);

end