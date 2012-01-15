function farmData()
%FARMDATA   Acquires training sets
%  FARMDATA() saves the acquired values in a subfolder of the current
%  path, plus a gest.mat file containing gestures name, ID and
%  #repetitions

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
%  FIXME: update

global PORT;
global SERIALCOMM;
global DBG;

PLOT = 1;


%---- OPENING PORT ------------------
try     % clear all handlers using our port
    fclose(instrfind({'Port','Status'},{PORT, 'open'}));
catch e %#ok<NASGU>
end
board = serial(PORT, ...
    'BaudRate', 57600, ...
    'InputBufferSize',  4590); % >1 sec of data
fopen(board);
%------------------------------------


if DBG;
    patient = 'lol';
    nMov = 3;
    nRep = 3;
    movName = {'close_hand'; ...
        'open_hand'; ...
        'ext_wrist'};
    
else    % acq GUI
    [nMov, movName, patient] = acqGUI();
    
    if(exist(patient,'dir') == 7)
        fprintf(' - WARNING: %s folder already exists, could overwrite data\n', patient);
    end
    
    nRep = input('Number of repetition per movement:\n');
    while(isempty(nRep) || nRep<2)
        nRep = input('Need at least 2 repetitions:\n');
    end
end

mkdir(patient);
mkdir([patient,'/ch1']);
mkdir([patient,'/ch2']);
mkdir([patient,'/ch3']);

gest = cell(nMov,3);    % {ID, movname, nRep}

global ACQ;
global THISREP;

for gID = 1:nMov
    for r = 1:nRep
        fprintf('------------------------------------------\n');
        fprintf('Gesture %d/%d (%s), rep %d/%d:\n', gID, nMov, movName{gID}, r, nRep);
        
        raw = fopen(sprintf('%s/%d-%d-%s.txt',patient,gID,r,movName{gID}), 'w');
        ch1 = fopen(sprintf('%s/ch1/%d-%d-%s.txt',patient,gID,r,movName{gID}), 'w');
        ch2 = fopen(sprintf('%s/ch2/%d-%d-%s.txt',patient,gID,r,movName{gID}), 'w');
        ch3 = fopen(sprintf('%s/ch3/%d-%d-%s.txt',patient,gID,r,movName{gID}), 'w');
        
        burstGUI(movName{gID}, r);
        
        while THISREP
            
            chunk = [];
            fscanf(board, '%c', 100); % flushing
            
            while ACQ
                if(board.BytesAvailable)
                    out = fscanf(board, '%c', 100);
                    disp(size(out));
                    [emg, chunk] = parseEMG(out, chunk);
                    fwrite(raw,out);
                    fwrite(ch1,emg(:,1));
                    fwrite(ch2,emg(:,2));
                    fwrite(ch3,emg(:,3));
                else
                    pause(.05);
                end
            end
            
            pause(.1);
        end
        
        fclose(raw);
        fclose(ch1);
        fclose(ch2);
        fclose(ch3);
        
    end
end

save([patient,'/gest.mat'], 'gest');

fclose(board)

fprintf('------------------------------------------');
fprintf('%s acquisition complete. Bye bye.\n', patient);

end