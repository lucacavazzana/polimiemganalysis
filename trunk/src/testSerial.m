clear all;
clc;

board = serial('COM6','BaudRate',57600,'Tag','EMGBoard'); % wrong port? Edit here!

fopen(board);

out=[];
for i=0:4
    out = fscanf(board);
end

disp(out);

fclose(board);
delete(board);