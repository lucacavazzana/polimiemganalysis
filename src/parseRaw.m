function parseRaw(folder)
% utility. Opens all raw files into FOLDER and separate channels into
% separate files

files = ls(sprintf('%s/*.txt', folder));

mkdir(sprintf('%s/ch1', folder));
mkdir(sprintf('%s/ch2', folder));
mkdir(sprintf('%s/ch3', folder));

for file = files'
    raw = fopen(sprintf('%s/%s', folder, file), 'r');
    ch1 = fopen(sprintf('%s/ch1/%s', folder, file), 'w');
    ch2 = fopen(sprintf('%s/ch2/%s', folder, file), 'w');
    ch3 = fopen(sprintf('%s/ch3/%s', folder, file), 'w');
    
    data = fscanf(raw,'%c',inf);
    ds = find(data == 'D');

    ch = [];
    ch(length(ds)-1,3) = 0;
    for ii = 1:(length(ds)-1)
        ch(ii,:) = sscanf(data(ds(ii)+2:end), '%d %d %d');
    end
    
    fprintf(ch1,'%d\n',ch(:,1));
    fprintf(ch2,'%d\n',ch(:,2));
    fprintf(ch3,'%d\n',ch(:,3));
    
    fclose(raw);
    fclose(ch1);
    fclose(ch2);
    fclose(ch3);
end

end