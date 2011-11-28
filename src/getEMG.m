function [ch rem out] = getEMG(board, rem)
%GETEMG
%   GETEMG(SP) - serial handled sp

global PORT;


if(~exist('sp','var'))
    if(isempty(PORT))
        if(ispc())
            PORT = 'COM6';
        else
            PORT = '/dev/ttyUSB0';
        end
        board = serial(PORT, ...
            'BaudRate', 57600);
    end
end

fopen(board);
board.BytesAvailable
out = fscanf(board);
fclose(board);

ds = find(out == 'D');
nSets = 0;

if(exist('rem', 'var'))
    if(isempty(ds))
        ch = [];
        rem = [rem, out];
        return;
    else
        ch(size(ds,2),3) = 0;    % preallocate
        rem = [rem, out(1:ds(1))]
        ch(1,:) = sscanf(rem(3:end),'%d')';
        nSets = 1;
    end
end

for i = 2:length(ds)
    nSets = nSets+1;
    ch(nSets,:) = sscanf(out(ds(i-1)+2:ds(i)), '%d')';
end

rem = out(ds(end):end);

end