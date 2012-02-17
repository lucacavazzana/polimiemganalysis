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
ch = zeros(0,3);

if( isempty(data) )
    return;
end

% write on file
if EB.dump~=-1
    fprintf(EB.dump);
end

ds = find(data == 'D'); % Ds indices
nSets = 0;

if( ~isempty(EB.chunk) ) % if chunk is not empty
    if(isempty(ds)) % not even a single complete set
        EB.chunk = [EB.chunk, data];
        return;
    else
        ch(size(ds,2),3) = 0;    % preallocate #D
        EB.chunk = [EB.chunk, data(1:ds(1))];
        ch(1,:) = sscanf(EB.chunk(3:end), '%d')';
        nSets = 1;
    end
end

if(length(ds)>1)
    for ii = 2:length(ds)
        nSets = nSets+1;
        
        out = sscanf(data(ds(ii-1)+2:ds(ii)), '%d')';
        if (size(out,2)==3)
            ch(nSets,:) = out;
            
        else % FIXME: BUGGED SERIAL BOARD?
            
            fprintf(['--------\n' ...
                'Bad serial output format [%d,%d]\n' ...
                '%s\n--------\n'], ...
                ds(ii-1), ds(ii), data(ds(ii-1):ds(ii)));
            ch(nSets,:)=ch(nSets-1,:);  % dunno how to manage here... info is lost anyway...
            warning('Bad serial output format');
            
        end
        
    end
    
    EB.chunk = data(ds(end):end);
    
end

end