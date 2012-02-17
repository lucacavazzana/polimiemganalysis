function movePinch(PM, s)
%PINCH perform precision grasp
%   PINCH(S) commands precision grasp at speed S (within 0 an 255).

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if ~exist('s','var')
    s = 255;
end

PM.move(1, 255, s, s);

end