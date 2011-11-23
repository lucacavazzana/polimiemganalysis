function farmData()
%FARMDATA   Acquires training sets
%   FARMDATA() saves the acquired values in a subfolder of the current
%   path, plus a gest.mat file containing gestures name, ID and
%   #repetitions

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com
%	FIXME: update

global PORT;
global SERIALCOMM;
global DEBUG;

PLOT = 1;

if DEBUG;
    patient = 'asd';
    nMov = 3;
    nRep = 3;
    movName = {'closeHand'; ...
            'openHand'; ...
            'wristExtension'};
else
    
%     while(~exist('patient','var') || isempty(patient))
%         patient = input('Insert patient name:\n','s');
%     end
    
    [nMov movName patient] = acqGUI();
    
    if(exist(patient,'dir') == 7)
        fprintf(' - WARNING: %s folder already exists, could overwrite data\n', patient);
    end
    
    nRep = input('Number of repetition per movement:\n');
    while(isempty(nRep) || nRep<2)
        nRep = input('Need at least 2 repetitions:\n');
    end
end

seq = 1;
gest = cell(nMov,3);    % {ID, movname, nRep}

for gID = 1:nMov
    disp('-----------------');
    fprintf('Gesture %d/%d (%s):\n', gID, nMov, movName{gID});
    for r = 1:nRep
        fprintf('Repetition %d/%d\n', r, nRep);
        ret = system([SERIALCOMM ' -a -d ' PORT ...
            ' -p ' patient ...
            ' -i ' sprintf('%d', gID) ...
            ' -s ' sprintf('%d', seq) ...
            ' -g ' movName{gID}]);
        
        if(ret~=0)
            error('Problems acquiring from serial');
        end
        
        % if true plots the current EMG acqusition
        if PLOT
            f = figure('NumberTitle', 'off', ...
                'Name', sprintf('%s %d/%d', movName{gID}, r, nRep));
            for i = 1:3
                if(ispc())
                    file = sprintf('%s\\ch%d\\%d-%d-%s.txt', patient, i, gID, seq, movName{gID});
                else
                    file = sprintf('%s/ch%d/%d-%d-%s.txt', patient, i, gID, seq, movName{gID});
                end
                fid = fopen(file, 'r');
                ch = fscanf(fid, '%d', [1 inf]);
                fclose(fid);
                subplot(3,1,i);               
                plot(ch);
                axis([0, length(ch), minmax(ch)]);
                ylabel(sprintf('Ch%d',i));
            end

            drawnow expose;
            disp('Press a key to continue...');
            pause();
            try
                close(f);
            catch e
            end
        end
        
        gest(gID,:) = {gID, movName{gID}, nRep};
        seq = seq+1;
    end
end

if(ispc())
    save([patient,'\gest.mat'], 'gest');
else
    save([patient,'/gest.mat'], 'gest');
end

fprintf('%s acquisition complete. Bye bye.\n', patient);

end