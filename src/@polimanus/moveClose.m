function moveClose(PM, s)
%   perform close hand movement

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

if ~exist('s','var')
    s = 255;
end

PM.move(255, 255, s, s);

end