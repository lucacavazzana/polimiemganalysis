function onlineRecogn()
%ONLINERECOGNITION  TODO
%

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
%  FIXME: update

global PORT;
global SERIALCOMM;
global DEBUG;

% system([SERIALCOMM ' -d ' PORT ' &']);
% ch1 = fopen('ch1','r');
% while(1)
%     asd = fscanf(ch1, '%d', [1, Inf]);
%     disp(asd);
% end

try
    fclose(instrfind({'Port','Status'},{PORT, 'open'}));
catch e
end

% open & init
board = serial(PORT, ...
    'BaudRate', 57600, ...
    'InputBufferSize',  4590); % >1 sec of data
fopen(board);

rem = [];

for i = 1:10
    try
        while(board.BytesAvailable < 32)
            pause(.0004);
        end
        out{i} = fscanf(board, '%c', board.BytesAvailable);
        [ch{i} rem] = parseEMG(out{i}, rem);
        
        % TODO: analysis
        
    catch e
        disp(e);
    end
end

keyboard

fclose(board);

end