function testParser()
%TESTPARSER Summary of this function goes here
%   Detailed explanation goes here

%   TAG: test

raw = fopen('dumpboard.txt', 'r');
data = fscanf(raw,'%c',inf);
fclose(raw);

size(data)

chunk = [];
old = 1; new = 5+randi(20);

while(new <= length(data))
    
    [out, chunk] = emgboard.parser(data(old:new), chunk);
    
    fprintf('%d - %d:\n%s\n\n', old, new, data(old:new));
    disp(out);
    disp(chunk);    
    
    old = new+1; new = new + 5 + randi(20);
    pause;
end

end

