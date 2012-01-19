function feats = testAnalyze()

patient = 'asd';
load([patient,'/gest.mat']);
feats = cell(size(gest,1),1);

for gg=1:size(gest,1) % for each gesture #ok<USENS>
    feats{gg}=cell(gest{gg,3},1);
    
    for rr=1:gest{gg,3} % for each repetition
        
        emg=[];
        
        for cc=3:-1:1
            f = fopen(sprintf('%s/ch%d/%d-%d-%s.txt', patient, cc, gest{gg,1}, rr, gest{gg,2}));
            emg(:,cc) = fscanf(f,'%d');
            fclose(f);
            %emg(end,3) = emg(end,end);  % dirty way to resize the vector to avoid reallocation in the next cycle
        end
        
        feats{gg}{rr} = analyzeEmg(emg, gest{gg,2});
        
    end
end

end