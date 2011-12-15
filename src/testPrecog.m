function testPrecog(patient, nets, tr)

%   test recognition rate on NETS 
% INPUT
%   PATIENT :	patient folder
%      NETS :   cell array containing the nets to test
%        TR :   cell array containing training records

global DBG;
JMP = 1;    % skip the loading part (to speedup debugging)

if JMP
    load('emgs.mat');
else
    
    if DBG
        patient = 'asd';
    end
    
    if(ispc())
        load([patient,'\gest.mat']);
    else
        load([patient,'/gest.mat']);
    end
    
    emgs = cell(size(gest,1),1);
    targets = [];
    
    for gg=1:size(gest,1) % for each gesture #ok<USENS>
        
        for rr=1:gest{gg,3} % for each repetition
            emg=[];
            
            for cc=1:3
                emg(:,cc) = convertFile2MAT(sprintf('%s\\ch%d\\%d-%d-%s.txt', ...
                    patient, cc, gest{gg,1}, rr, gest{gg,2}));
                emg(end,3) = emg(end,end);  % dirty way to resize the vector to avoid reallocation in the next cycle
            end
            
            emgs{gg} = [emgs{gg} analyzeEmg(emg, 'emg')];
        end
        targets = [targets gg*ones(length(emgs{gg}),1)]; %#ok<AGROW>
    end
    
    emgs = [emgs{:}];
    
    clear emg;
end

keyboard;

PERC = 1;   % if 1 compute over length %, over fixed step otherwise

if PERC
    step = 20;
    resps = zeros(1,step);
else
    step = 20;
    resps = zeros(1,round(1000/step));
end
tot = resps;

for nn = 1:length(nets)    
    for ii = tr{nn}.testInd
        
        fprintf('- net %d, burst %d\n', nn, ii);
        
        if PERC
            for ll = 1:step
                fprintf('%.2f ',ll/step);
                tail = floor(length(emgs{ii})*ll/step);
                feat = extractFeatures(emgs{ii}(1:tail,:));
                [~, res] = max(sim(nets{nn}, feat));
                tot(ll) = tot(ll)+1;
                resps(ll) = resps(ll) + (res==targets(ii));
            end
        else
            for ll = 1:floor(length(emgs{ii})/step)
                tail = step*ll;
                fprintf('%d ',tail);
                feat = extractFeatures(emgs{ii}(1:tail,:));
                [~, res] = max(sim(nets{nn}, feat));
                tot(ll) = tot(ll)+1;
                resps(ll) = resps(ll) + (res==targets(ii));
            end
        end
    end
end

if PERC
    save('perc.mat');
    bar(100/step:100/step:100, resps./tot);
    xlabel('burst percentage');
else
    save('step.mat');
    last = find(tot, 1, 'last');
    bar(step*(1:last), resps(1:last)./tot(1:last));
    xlabel('burst length');
end
ylabel('recognition rate');

end