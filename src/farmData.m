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

if DEBUG;
    patient = 'asd';
    nMov = 3;
    nRep = 3;
    movName = {'closeHand'; ...
            'openHand'; ...
            'wristExtension'};
else
    
    while(~exist('patient','var') || isempty(patient))
        patient = input('Insert patient name:\n','s');
    end
    
    if(exist(patient,'dir') == 7)
        fprintf(' - WARNING: %s folder already exists, could overwrite data\n', patient);
    end
    
    [nMov movName] = gestGUI();
    
    nRep = input('Number of repetition per movement:\n');
    while(isempty(nRep) || nRep<3)
        nRep = input('Need at least 3 repetitions:\n');
    end
end

gID = 1;
seq = 1;

gest = cell(nMov,3);    % {ID, movname, nRep}

for m = 1:nMov
    disp('-----------------');
    fprintf('Gesture %d/%d%s:\n', m, nMov, all(size(movName{m}))*[' (' movName{m} ')']);
    for r = 1:nRep
        fprintf('Repetition %d/%d\n', r, nRep);
        ret = system([SERIALCOMM ' -a -p ' patient ' -i ' sprintf('%d', m) ...
            ' -s ' sprintf('%d', seq) ...
            all(size(movName{m}))*[' -g ' movName{m}]]);
        
        if(ret~=0)
            error('Problems acquiring from serial');
        end
        
        if DEBUG
            f = figure;
            for i = 1:3
                fid = fopen(sprintf('%s\\ch%d\\%d-%d-%s.txt', patient, i, m, r, movName{m}), 'r');
                ch = fscanf(fid, '%d', [1 inf]);
                fclose(fid);
                subplot(3,1,i);               
                plot(ch);
                axis([0, length(ch), minmax(ch)]);
            end
            disp('Press a key to continue');
            pause();
            try
                close(f);
            catch e
            end
        end
        
        gest(m,:) = {m, movName{m}, nRep};
        seq = seq+1;
    end
end

if(ispc())
    save([patient,'\gest.mat'], 'gest');
else
    save([patient,'/gest.mat'], 'gest');
end

end