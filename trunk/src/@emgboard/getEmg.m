function [ch data] = getEmg(EB, w)
%GETEMG get parsed EMG signal from ERACLE.
%   [CH DATA] = EB.GETEMG(W) get and parses the signal from the EMG board
%   and returns the signal CH as Nx3 matrix, where N is the signal length
%   and 3 the number of channels. If W is given and not zero, the call will
%   be blocking. If specified, DATA is the raw output from the serial.
%
%   NOTE: too much time between two consecutive serial reading (ie: long
%   analysis time) could cause the input buffer to fill, thus losing data.
%   This way the parser could be unable to concatenate the two outputs.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(~(nargin>1 && exist('w','var')))
    w = 0;
end

data = EB.getRaw(w);

if( isempty(data) )
    ch = zeros(0,3);
    return;
end

% write log on file
if EB.dumpH~=-1
    fprintf(EB.dumpH, data);
end

% parsing
[ch, EB.chunk]= emgboard.parser(data, EB.chunk);

end