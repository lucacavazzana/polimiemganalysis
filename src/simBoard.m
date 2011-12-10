function [emg] = simBoard()

global DATA;
global pnt;

if isempty(DATA)
    tic
    DATA(:,3) = convertFile2MAT('asd\\ch3\\1-1-close_hand.txt');
    DATA(:,2) = convertFile2MAT('asd\\ch2\\1-1-close_hand.txt');
    DATA(:,1) = convertFile2MAT('asd\\ch1\\1-1-close_hand.txt');
    pnt = 0;
end

if(pnt == size(DATA,1))
    error('no more data');
end

if(1) %pnt<110)
    n = 10+randi(50);
else
    n = ceil(toc*270);  % syms 270 signals per sec
    tic;    % reset
end

if(pnt+n>size(DATA,1))
    emg = DATA(pnt+1:end,:);
    pnt = size(DATA,1);
    disp('WARNING, NO MORE DATA, I''M GONNA CRASH!');
else
    emg = DATA(pnt+1:pnt+n,:);
    pnt = pnt+n;
end
end