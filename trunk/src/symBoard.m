function [emg] = symBoard()

global DATA;
global pnt;

if isempty(DATA)
    disp('empty');
    DATA(:,3) = convertFile2MAT('asd\\ch3\\1-1-close_hand.txt');
    DATA(:,2) = convertFile2MAT('asd\\ch2\\1-1-close_hand.txt');
    DATA(:,1) = convertFile2MAT('asd\\ch1\\1-1-close_hand.txt');
    pnt = 0;
end

n = 10+randi(50);

if(pnt == size(DATA,1))
    error('no more data');
end

if(pnt+n>size(DATA,1))
    emg = DATA(pnt+1:end,:);
    pnt = size(DATA,1);
    disp('NO MORE DATA');
else
    emg = DATA(pnt+1:pnt+n,:);
    pnt = pnt+n;
end
end