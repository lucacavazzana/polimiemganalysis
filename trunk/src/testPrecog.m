function testPrecog(patient, net)

global DBG;
JMP = 0;    % skip the loading part (to speedup debugging)

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
    

    load('halfNet.mat');
    
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
        targets = [targets; gg*ones(length(emgs{gg}),1)]; %#ok<AGROW>
    end
    
    emgs = [emgs{:}];
    
end

step = 20;
resps = zeros(1,round(1000/step));
conta = resps;
for ii = tr.testInd
    
    for ll = 1:floor(length(emgs{ii})/step)
        
        tail = step*ll;
        feat = [extractFeatures(emgs{ii}(1:tail,1)); ...
            extractFeatures(emgs{ii}(1:tail,2)); ...
            extractFeatures(emgs{ii}(1:tail,3))];
        [~, res] = max(sim(net, feat));
        resps(ll) = resps(ll)+(res==targets(ii));
        conta(ll) = conta(ll)+1;
    end
end
save('spam2.mat');
last = find(conta, 1, 'last');
bar(step*(1:last), resps(1:last)./conta(1:last));

% resps = zeros(1,10);
% for ii = tr.testInd
%     fprintf('testing %d\n', ii);
%     step = .1*length(emgs{ii});
%     for ll = 1:10
%         tail = round(ll*step);
%         feat = [extractFeatures(emgs{ii}(1:tail,1)); ...
%             extractFeatures(emgs{ii}(1:tail,2)); ...
%             extractFeatures(emgs{ii}(1:tail,3))];
%         [~, res] = max(sim(net, feat));
%         resps(ll) = resps(ll)+(res==targets(ii));
%     end
% end
% bar(resps/length(tr.testInd));
% pause;

end