function onlineRecogn()
%ONLINERECOGNITION  TODO
%

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
%  FIXME: update

global PORT;
global SERIALCOMM; %#ok<NUSED>
global DBG;

DUMP = 0;   % debugging
DRAW = 1;

% system([SERIALCOMM ' -d ' PORT ' &']);
% ch1 = fopen('ch1','r');
% while(1)
%     asd = fscanf(ch1, '%d', [1, Inf]);
%     disp(asd);
% end

try     % clear all handlers using our port
    fclose(instrfind({'Port','Status'},{PORT, 'open'}));
catch e %#ok<NASGU>
end

if DUMP
    dmp = fopen('dump.txt','w'); %#ok<UNRCH>
end

raw(270,3)=0; % 1 sec of acquisitions
tail = [];

% init & open
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

if DBG
    s{1}.new=newCh;
    s{1}.first=first;
    s{1}.last=last;
    s{1}.raw=raw;
end

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
        last = newLast;
    else
        newLast = newLast-first+1;  % now equal to the total lenght
        if(newLast<271)
            raw(1:newLast) = [raw(first:last,:); newCh];
            first=1; last=newLast;
        else
            warning('EMGAnalysis:inputBuffer', ...
                ['Computation between acquisition takes too much time, ' ...
                'consider resizing the circular buffer']);
            raw = [raw(first+newLast-270:last,:); newCh];
            first=1; last=270;
        end
    end
    
    if DBG
        s{i}.new=newCh;
        s{i}.first=first;
        s{i}.last=last;
        s{i}.raw=raw;
    end
    
    if DRAW
        %clf(f);
        plotEmg(raw(first:last,:), f, sprintf('asd %d %d %d', i, first, last));
        drawnow;
        f = figure;
    end
end

save('asd.mat');
fclose(board);
close(f);
end