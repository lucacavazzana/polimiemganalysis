function movePinch(PM, s)
%PINCH Perform precision grasp movement
%   PM.MOVEPINCH(S) command pinch movement with speed S (within 0 an 255).

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(nargin==1)
    s = 255;
end

PM.move(1, 255, s, s);

end