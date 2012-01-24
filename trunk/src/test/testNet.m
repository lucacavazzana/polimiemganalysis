function testNet(net)

close all;

if(~exist('net','var')||isempty(net))
    load('net.mat','net');
    net = net{1};
end

PATIENT = 'asd';
DRAW = 1;

% initializing network struct
net = nn.hints(net);
if net.hint.zeroDelay, nnerr.throw('Network contains a zero-delay loop.'); end
netStr = struct(net);

files = dir([PATIENT, '/ch1/']);
files = files(~[files.isdir]);

if DRAW
    figure;
end

for ii = 1:length(files)
    clear emg;
    % reading file
    emg(:,3) = convertFile2MAT([PATIENT,'/ch3/',files(ii).name]);
    emg(:,2) = convertFile2MAT([PATIENT,'/ch2/',files(ii).name]);
    emg(:,1) = convertFile2MAT([PATIENT,'/ch1/',files(ii).name]);
    
    fprintf(' - Analyzing %s:\n',files(ii).name);
       
    feats = analyzeEmg(emg, 'feats', .5, 'ica');
    if DRAW
        bursts = analyzeEmg(emg, 'emg', .5);
        drawnow;
    end
        
    for ff = 1:length(feats)
        
        nnRes = mySim(netStr, feats{ff});
        
        fprintf('--- %s - burst %d/%d   ---', files(ii).name, ff, length(feats));
        fprintf('   %.3f', nnRes);
        fprintf('\n');
        fprintf('gesture %d\n', find(nnRes>.5));
        
        if DRAW % drawing
            clf;
            subplot(3,1,1);
            plot(bursts{ff}(:,1));
            title(sprintf('%s - burst %d/%d', files(ii).name, ff, length(feats)));
            subplot(3,1,2);
            plot(bursts{ff}(:,2));
            subplot(3,1,3);
            plot(bursts{ff}(:,3));
            drawnow;
            
            pause;
        end
    end
    
    pause;
end

end