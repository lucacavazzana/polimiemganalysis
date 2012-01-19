function [emg] = simBoard2()

% this function simulates the EMG board from a set of parsed emg txt file

global BOARD;
global pnt;

if isempty(BOARD)
    tic
    BOARD(:,3) = convertFile2MAT('asd\\ch3\\1-1-close_hand.txt');
    BOARD(:,2) = convertFile2MAT('asd\\ch2\\1-1-close_hand.txt');
    BOARD(:,1) = convertFile2MAT('asd\\ch1\\1-1-close_hand.txt');
    pnt = 0;
end

if(pnt == size(BOARD,1))
    error('no more data');
end

if(pnt<110)
    n = 10+randi(50);
else
    n = ceil(toc*270);  % syms 270 signals per sec
    tic;    % reset
end

if(pnt+n>size(BOARD,1))
    emg = BOARD(pnt+1:end,:);
    pnt = size(BOARD,1);
    disp('WARNING, NO MORE BOARD, I''M GONNA CRASH!');
else
    emg = BOARD(pnt+1:pnt+n,:);
    pnt = pnt+n;
end
end