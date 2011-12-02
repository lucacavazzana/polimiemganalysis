function testTraining(patient)

global DBG;    % debug

if DBG
    patient = 'asd';
end

% loading gesture info
if(ispc())
    load([patient,'\gest.mat']);
else
    load([patient,'/gest.mat']);
end

feats = cell(size(gest,1),1);

% extracting bursts and features
for gg=1:size(gest,1) % for each gesture #ok<USENS>
    feats{gg}=cell(gest{gg,3},1);
    
    for rr=1:gest{gg,3} % for each repetition
        emg=[];
        
        for cc=1:3
            f = fopen(sprintf('%s\\ch%d\\%d-%d-%s.txt', patient, cc, gest{gg,1}, rr, gest{gg,2}));
            emg(:,cc) = fscanf(f,'%d');
            fclose(f);
            emg(end,3) = emg(end,end);  % dirty way to resize the vector to avoid reallocation in the next cycle
        end
        
        feats{gg}{rr} = analyzeEmg(emg, gest{gg,2});
        
    end
end

keyboard;

for ii=1:size(gest,1)
    feats{ii} = {[feats{ii}{:}]};
end

% now train the NN


end