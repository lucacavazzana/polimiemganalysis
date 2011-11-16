function farmData()
%FARMDATA   Acquires training sets
%   FARMDATA() saves the acquired values in a subfolder of the current
%   path, plus a gest.mat file containing gestures name, ID and
%   #repetitions

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com
%	FIXME: update

clc;

global PORT;
global SERIALCOMM;
global DEBUG;

if DEBUG-1;
    patient = 'asd';
    nMov = 3;
    nRep = 3;
    movName = cell(1,nMov);
else
    
    % place the GUI here
    
    while(~exist('patient','var')|| isempty(patient))
        patient = input('Insert patient name:\n','s');
    end
    
    if(7==exist(patient,'dir'))
       fprintf(' - WARNING: %s folder already exists, could overwrite data\n', patient);
    end
    
    [nMov movName] = gestGUI();
%     nMov = input('Number of movements:\n');
%     while(isempty(nMov) || nMov<2)
%         nMov = input('Need at least 2 movements:\n');
%     end
%     movName = cell(1,nMov);
%     for i  = 1:nMov
%         movName{i} = input(sprintf('Movement %d name (optional):\n', i), 's');
%         if(isempty(movName{i}))
%             break;
%         end
%     end
    
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
    fprintf('Gesture %d/%d:\n', m, nMov);
    for r = 1:nRep
        fprintf('Repetition %d/%d\n', r, nRep);
        ret = system([SERIALCOMM ' -a -p ' patient ' -i ' sprintf('%d', m) ...
            ' -s ' sprintf('%d', seq) ...
            all(size(movName{m}))*[' -g ' movName{m}]]);
        
        if(ret~=0)
            error('Problems acquiring from serial');
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