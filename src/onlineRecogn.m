function onlineRecogn()
%ONLINERECOGNITION  TODO
%

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
%  FIXME: update

global PORT;
global SERIALCOMM; %#ok<NUSED>
global DBG; %#ok<NUSED>

DUMP = 0;   % debugging
DRAW = 1;

% system([SERIALCOMM ' -d ' PORT ' &']);
% ch1 = fopen('ch1','r');
% while(1)
%     asd = fscanf(ch1, '%d', [1, Inf]);
%     disp(asd);
% end

try
    fclose(instrfind({'Port','Status'},{PORT, 'open'}));
catch e %#ok<NASGU>
end

if DUMP
    dmp = fopen('dump.txt','w'); %#ok<UNRCH>
end

raw(270,3)=0; % 1 sec of acquisitions
tail = [];

% open & init
board = serial(PORT, ...
    'BaudRate', 57600, ...
    'InputBufferSize',  4590); % >1 sec of data
fopen(board);

if DRAW
    f = figure;
    drawnow;
end


while(board.BytesAvailable < 32)
    pause(.1);
end
out = fscanf(board, '%c', board.BytesAvailable);

if DUMP
        fwrite(dmp,out); %#ok<UNRCH>
end

[newCh tail] = parseEMG(out,tail);
newCh = abs(newCh-512); % preprocessing
first = 1; last = size(newCh,1);
raw(1:last,:)=newCh;

for i = 2:10
    while(board.BytesAvailable < 32)
        pause(.1);
    end
    out = fscanf(board, '%c', board.BytesAvailable);
    
    if DUMP
        fwrite(dmp,out); %#ok<UNRCH>
    end
    
    [newCh tail] = parseEMG(out,tail);
    newCh = abs(newCh-512);
    
    newLast = last+size(newCh,1);
    if(newLast<270)
        raw(last+1:newLast,:) = newCh;
    else
        newLast = newLast-270;
        raw([last+1:270, 1:newLast],:) = newCh;
    end
    
    if((last<first && first<newLast) || ...
            (first<newLast && newLast<last))
        warning('Circular buffer too small or computations too heavy!');
        
        fprintf('first %d, last %d, newLast %d\n', first, last, newLast);
        first = rem(newLast,270)+1; %if(newLast==270) first=1 else first=newLast+1
    end
    last = newLast;
    
    if DRAW
        %clf(f);
        if(first<last)
            plotEmg(newCh, f, sprintf('asd %d %d %d', i, first, last));
        else
            try
                plotEmg(raw([first:end,1:last],:), f, sprintf('asd %d %d %d', i, first, last));
            catch e
                save('dump.mat');
                fclose all;
                close all;
                throw(addCause(e.identifier, MException(0,'fottuto errore. first %d, last %d', first, last)))
            end
        end
        drawnow;
        f = figure;
    end
end

fclose(board);
close(f);
end