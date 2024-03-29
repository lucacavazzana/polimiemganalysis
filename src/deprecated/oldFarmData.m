function oldFarmData()
%FARMDATA   Acquires training sets
%  FARMDATA() saves the acquired values in a subfolder of the current
%  path, plus a gest.mat file containing gestures name, ID and
%  #repetitions.
%  Calls the external serialcomm.exe

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
%  FIXME: update

close all;

global PORT;
global SERIALCOMM;

DBG = 0;
PLOT = 1;

if ( exist('DBG','var') && DBG )
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

gest = cell(nMov,3);    % {ID, movname, nRep}

for gID = 1:nMov
    fprintf('---------------------\n');
    fprintf('Gesture %d/%d (%s):\n', gID, nMov, movName{gID});
    fprintf('---------------------\n');
    for r = 1:nRep
        fprintf('\n -- %s %d/%d -- \n', movName{gID}, r, nRep);
        ret = system(sprintf('%s -a -d %s -p %s -i %d -s %d -g %s', ...
            SERIALCOMM, PORT, patient, gID, r, movName{gID}));
%         ret = system([SERIALCOMM ' -a -d ' PORT ...
%             ' -p ' patient ...
%             ' -i ' sprintf('%d', gID) ...
%             ' -s ' sprintf('%d', r) ...
%             ' -g ' movName{gID}]);
        
%         if(ret~=0)
%             error('Problems acquiring from serial');
%         end
        assert(ret==0,'Problems acquiring from serial');
        
        % if true plots the current EMG acqusition
        if PLOT
            
            f = plotEmgFile(patient, r, gID, movName{gID});
            
            disp('Press a key to continue...');
            pause();
            try
                close(f);
            catch e %#ok<NASGU>
            end
        end
        
        gest(gID,:) = {gID, movName{gID}, nRep};
    end
end

save([patient,'/gest.mat'], 'gest');

fprintf('\n\n%s acquisition complete. Bye bye.\n', patient);

end