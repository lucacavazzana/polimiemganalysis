patient = 'asd';
gesture = '1-1-close_hand';

f1 = fopen(sprintf('%s\\ch1\\%s.txt',patient,gesture),'r');
f2 = fopen(sprintf('%s\\ch2\\%s.txt',patient,gesture),'r');
f3 = fopen(sprintf('%s\\ch3\\%s.txt',patient,gesture),'r');
raw = fopen(sprintf('%s\\raw.txt',patient),'w');

n = randi(100);

while(1)
    
    if(n==100)
        fprintf(raw,'I:a b c\n');
        n=0;
    end
    n = n+1;
    
    r1 = fscanf(f1,'%d',1);
    r2 = fscanf(f2,'%d',1);
    r3 = fscanf(f3,'%d',1);
    if(isempty(r1))
        break;
    end
    fprintf(raw,'D:%d %d %d\n',r1,r2,r3);
end

fclose(f1);
fclose(f2);
fclose(f3);
fclose(raw);