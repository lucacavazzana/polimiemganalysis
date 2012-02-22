function testNet(folder, net, varargin)
%   ...
%
%   TESTNET(FOLDER, NET, ...)
%
% INPUT -
%    FOLDER :   files folder name
%
% OPTIONAL -
%       NET :   network instance or filename where the net is stored
%    'plot' :

%   TAG: test

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

close all;

if nargin == 0
    folder = 'asd';
end

if(~(nargin>1 && ~isempty(net)))
    load([folder, '/net.mat'],'nets');
    net = nets{1};
    clear nets;
    
elseif(ischar(net))
    load('net.mat','nets');
    net = nets{1};
    clear nets;
end

% creating network obj
if(strcmp(class(net),'network'))
    net = emgnet(net);
end

PLOT = 0;

for ii = 1:length(varargin)
    switch(varargin{ii})
        case 'plot'
            PLOT = 1;
            fig = 0;
    end
end

files = dir(sprintf('%s/ch1/*.txt', folder));

emg = emgsig(emgboard.sRate);

for ii = 1:length(files)
    
    % reading file
    emg.setSignal( getSig(folder, files(ii).name) );
    nb = emg.findBursts();
    feats = emg.extractFeatures();
    
    fprintf(' - Analyzing %s:\n',files(ii).name);
    
    for ff = 1:nb
        
        res = sim(net, feats{ff});
        
        fprintf('--- %s - burst %d/%d   ---\n', files(ii).name, ff, length(feats));
        fprintf('gesture ');
        fprintf('%d ', find(res>.5));
        fprintf('(');
        fprintf('   %.3f', res);
        fprintf('   )\n');
        
%         keyboard;
        if PLOT % drawing
            
            if(fig==0)
                fig = figure;
            end
            
            emg.plotBurst(ff,fig);
            pause;
        end
    end
    
    if PLOT
        emg.plotSignal(fig);
    end
    
    fprintf('\npress a key to continue\n');
    pause;
end


    function ch = getSig(folName, fileName)
        ch(:,3) = convertFile2MAT([folName,'/ch3/',fileName]);
        ch(:,2) = convertFile2MAT([folName,'/ch2/',fileName]);
        ch(:,1) = convertFile2MAT([folName,'/ch1/',fileName]);
    end

end