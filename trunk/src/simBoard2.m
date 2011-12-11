function [raw] = simBoard2()

global BOARD;
global POS;

if(isempty(BOARD))
    tic;
    BOARD = fopen('asd\raw.txt');
    POS = 0;
    TIME = 0;
    pause(.05);
end

% elapsed time from last acquisition
n = round(toc*15*270);  % 270 sample/sec * 15(average) char/sample
tic;
% n = 40+randi(10);

fseek(BOARD,POS,'bof');
raw = fscanf(BOARD, '%c', n);
POS = ftell(BOARD);

if(isempty(raw))
    error('NO MORE DATA');
end

end