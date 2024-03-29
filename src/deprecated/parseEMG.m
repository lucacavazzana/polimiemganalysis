function [ch, rem] = parseEMG(data, rem)
%PARSEEMG   return the parsed raw EMG data
%  [CH REM] = PARSEEMG(DATA, REM) parses the raw ascii DATA acquired from
%  the emg board (as [D:## ## ##]+) and returns it as a Nx3 matrix CH (a
%  column for each channel). The returned REM vector is a string containing
%  the chars of the last, incomplete set. The same chunk has to be feed as
%  input for the next call of the function if you want multiple continuous
%  acquisitions.
%
%  BEWARE! Too much time between two serial reading (ie: heavy computation)
%  could cause to miss some emg sets, crashing this function (due to a
%  mismatch between REM and the starting chunk of the new acquisition).

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
%  FIXME: update

try

ds = find(data == 'D'); % Ds indices
nSets = 0;

if( nargin>1 && ~isempty(rem) ) % if REM exists and is not empty
    if(isempty(ds)) % not even a single complete set
        ch = [];
        rem = [rem, data];
        return;
    else
        ch(size(ds,2),3) = 0;    % preallocate #D 
        rem = [rem, data(1:ds(1))];
        ch(1,:) = sscanf(rem(3:end),'%d')';
        nSets = 1;
    end
end

if(length(ds)>1)
    for ii = 2:length(ds)
        nSets = nSets+1;
        
        try
        ch(nSets,:) = sscanf(data(ds(ii-1)+2:ds(ii)), '%d')';
        catch e
            fprintf('--------\nMissing channel? [%d,%d]\n%s\n--------\n', ...
                ds(ii-1), ds(ii), data(ds(ii-1):ds(ii)));
            keyboard;
        end
    end
end

rem = data(ds(end):end);

catch e
    keyboard
end

end