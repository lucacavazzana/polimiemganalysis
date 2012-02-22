function [ch data] = getEmg(EB, w)
%GETEMG sparse emg signal from emgboard.
%   [CH DATA] = GETEMG(W) parses data from the emgboard and returns the 
%   signal as Nx3 matrix, where N is the signal length, 3 the number of 
%   channels. If W is given and not zero, GETEMG will wait for new data if 
%   the serial buffer is empty (or return an empty CH otherwise). DATA is
%   the raw otput from the serial.
%
%   BEWARE! Too much time between two serial reading (ie: long analysis
%   time) could let the serial buffer to fill, missing some emg samples
%   and crashing this function when trying to concatenate the new chunk
%   with the old one.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(~exist('w','var'))
    w = 0;
end

data = EB.getRaw(w);

if( isempty(data) )
    return;
end

% write log on file
if EB.dumpH~=-1
    fprintf(EB.dumpH, data);
end

% parsing
[ch, EB.chunk]= emgboard.parser(data, EB.chunk);

end