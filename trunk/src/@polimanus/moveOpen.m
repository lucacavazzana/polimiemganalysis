function moveOpen(PM, s)
%   perform open hand movement

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

if ~exist('s','var')
    s = 255;
end

PM.move(1, 1, s, s);

end