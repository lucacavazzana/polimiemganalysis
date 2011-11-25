function onlineRecogn()

global PORT;
global SERIALCOMM;
global DEBUG;

system([SERIALCOMM ' -d ' PORT ' &']);

ch1 = fopen('ch1','r');

while(1)
    asd = fscanf(ch1, '%d', [1, Inf]);
    disp(asd);
end

end