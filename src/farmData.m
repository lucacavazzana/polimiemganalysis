function farmData()
%FARMDATA   Acquires training sets

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com
%	FIXME: update

clc;

global PORT;
global SERIALCOMM;
global DEBUG;

if exist('DEBUG','var');
    patient = 'asd';
    nMov = 3;
    nRep = 3;
    movName = cell(1,nMov);
else

    while(~exist('patient','var')|| isempty(patient))
        patient = input('Insert patient name:\n','s');
    end
    nMov = input('Number of movements:\n');
    while(isempty(nMov) || nMov<2)
        nMov = input('Need at least 2 movements:\n');
    end
    movName = cell(1,nMov);
    for i  = 1:nMov
        movName{i} = input(sprintf('Movement %d name (optional):\n', i), 's');
        if(isempty(movName{i}))
            break;
        end
    end
    nRep = input('Number of repetition per movement:\n');
    while(isempty(nRep) || nRep<3)
        nRep = input('Need at least 3 repetitions:\n');
    end
end

gID = 1;
seq = 1;

for m = 1:nMov
    disp('-----------------');
    fprintf('Gesture %d :\n', m);
    for r = 1:nRep
        fprintf('Repetition %d/%d\n', r, nRep);
        system([SERIALCOMM ' -a -p ' patient ' -i ' sprintf('%d', m) ...
            ' -s ' sprintf('%d', seq) ...
            all(size(movName{m}))*[' -g ' movName{m}]]);
        seq = seq+1;
    end
end

end