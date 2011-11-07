board = serial('COM6', 'Tag', 'EMGBoard'); %, 'Tag', 'EMGboard');  % wrong port? Edit here!

try
    fopen(board);
catch e
    
end

[out, size] = fread(board);
disp(out');


fclose(board);
delete(board);