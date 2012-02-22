function newFarmData(PORT)
%FARMDATA   Acquires training sets
%   FARMDATA(PORT) saves the acquired values in a subfolder of the current
%   path, plus a gest.mat file containing gestures name, ID and
%   #repetitions. If specified opens the board on PORT.
%   Uses builtin Matlab serial communication.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

DBG = 0;
PLOT = 1;

if( nargin == 0)
    PORT = [];
end

%---- OPENING PORT ------------------
try     % clear all handlers using our port
    fclose(instrfind({'Tag','Status'},{'EmgBoard', 'open'}));
catch e %#ok<NASGU>
end

board = emgboard(PORT);
board.open;
%------------------------------------

if DBG;
    patient = 'lol';
    nMov = 3;
    nRep = 3;
    movName = {'close_hand'; ...
        'open_hand'; ...
        'ext_wrist'};
    
else    % acq GUI
    [nMov, nRep, movName, patient] = acqGUI();
    
    if(exist(patient,'dir') == 7)
        fprintf(' - WARNING: %s folder already exists, could overwrite data\n', patient);
        cnt = input('Continue? [Y/n] ','s');
        if(cnt == 'n')
            return;
        end
    end
    
end

if(exist(patient,'dir')~=7)
    mkdir(patient);
end
% if(exist([patient,'/ch1'],'dir')~=7)
%     mkdir([patient,'/ch1']);
% end
% if(exist([patient,'/ch2'],'dir')~=7)
%     mkdir([patient,'/ch2']);
% end
% if(exist([patient,'/ch3'],'dir')~=7)
%     mkdir([patient,'/ch3']);
% end

gest = cell(nMov,3);    % {ID, movname, nRep}

global ACQ;
global THISREP;

disp('flushing. Don''t worry if warnings appear');
board.getEmg;
clc;

% keyboard
for gID = 1:nMov
    
    gest(gID,:) = {gID, movName{gID}, nRep};
    
    for r = 1:nRep
        fprintf('------------------------------------------\n');
        fprintf('Gesture %d/%d (%s), rep %d/%d:\n', ...
            gID, nMov, movName{gID}, r, nRep);
        
        raw = fopen(sprintf('%s/%d-%d-%s.txt', ...
            patient,gID,r,movName{gID}), 'w');
%         ch1 = fopen(sprintf('%s/ch1/%d-%d-%s.txt', ...
%             patient,gID,r,movName{gID}), 'w');
%         ch2 = fopen(sprintf('%s/ch2/%d-%d-%s.txt', ...
%             patient,gID,r,movName{gID}), 'w');
%         ch3 = fopen(sprintf('%s/ch3/%d-%d-%s.txt', ...
%             patient,gID,r,movName{gID}), 'w');
        
        if PLOT
            f = figure;
%             title('ready for acquisition');
            drawnow;
            sig = emgsig(board.sRate);
        end
        
        burstGUI(movName{gID}, r);
        
        while(THISREP)
            
            if(ACQ)
                [ch, rawOut] = board.getEmg;
                
%                 fprintf(ch1,'%d\n',ch(:,1));
%                 fprintf(ch2,'%d\n',ch(:,2));
%                 fprintf(ch3,'%d\n',ch(:,3));
                fwrite(raw,rawOut);
                
                if PLOT
                    sig.add(ch);
                    sig.plotSignal(f);
                    sig.clearSignal;
                end
                
            else    % just flush
                ch = board.getEmg;
                if PLOT
                    sig.add(ch);
                    sig.plotSignal(f);
                    sig.clearSignal;
                end
            end
            
            pause(.1);
        end
        
        if PLOT
            close(f);
        end
        
        fclose(raw);
%         fclose(ch1);
%         fclose(ch2);  
%         fclose(ch3);
        
    end
end

save([patient,'/gest.mat'], 'gest');

board.close;

fprintf('------------------------------------------\n');
fprintf('call "parseRaw" to separate channels into different files\n');
fprintf('%s acquisition complete. Bye bye.\n', patient);

end