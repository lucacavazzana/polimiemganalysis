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

if DBG;
    patient = 'lol';
    nMov = 3;
    nRep = 3;
    movName = {'close_hand'; ...
        'open_hand'; ...
        'ext_wrist'};
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

gest = cell(nMov,3);    % {ID, movname, nRep}

for gID = 1:nMov
    disp('---------------------');
    fprintf('Gesture %d/%d (%s):\n', gID, nMov, movName{gID});
    disp('---------------------');
    for r = 1:nRep
        fprintf('\n -- Repetition %d/%d -- \n', r, nRep);
        ret = system([SERIALCOMM ' -a -d ' PORT ...
            ' -p ' patient ...
            ' -i ' sprintf('%d', gID) ...
            ' -s ' sprintf('%d', r) ...
            ' -g ' movName{gID}]);
        
        if(ret~=0)
            error('Problems acquiring from serial');
        end
        
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

if(ispc())
    save([patient,'\gest.mat'], 'gest');
else
    save([patient,'/gest.mat'], 'gest');
end

fprintf('%s acquisition complete. Bye bye.\n', patient);

end