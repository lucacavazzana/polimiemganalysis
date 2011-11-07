board = serial('COM3', 'Tag', 'EMGBoard'); % wrong port? Edit here!

fopen(board);

out=[];
for i=0:4
    out = [out; fread(board)];
end

for i=1:5
    plot(out(i,:));
    pause;clear
end

fclose(board);
delete(board);