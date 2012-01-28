function movePinch(PM, s)
%   perform pinch movement

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

if ~exist('s','var')
    s = 255;
end

PM.move(1, 255, s, s);

end