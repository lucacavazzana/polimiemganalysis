function ch = getEmg(EB, w)
%
%  BEWARE! Too much time between two serial reading (ie: heavy computation)
%  could cause to miss some emg sets, crashing this function (due to a
%  mismatch between REM and the starting chunk of the new acquisition).

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

if(~exist('w','var'))
    w = 0;
end

data = EB.getRaw(w);
ch = zeros(0,3);

if( isempty(data) )
    return;
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
        
        try
            ch(nSets,:) = sscanf(data(ds(ii-1)+2:ds(ii)), '%d')';
        catch e     % FIXME: BUGGED SERIAL BOARD?
            fprintf(['--------\n' ...
                'Missing channel? [%d,%d]\n' ...
                '%s\n--------\n'], ...
                ds(ii-1), ds(ii), data(ds(ii-1):ds(ii)));
            ch(nSets,:)=ch(nSets-1,:);
            warning('Missing channel');
        end
    end
    
    EB.chunk = data(ds(end):end);
    
end

end