function ch = getEmg(DB)
%GETEMG returns simulated emg signal
%   CH = GETEMG() returns the simulated emg signal as Nx3 matrix, where N
%   is signal length.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if(DB.last == 0)
    tic;
    pause(0.001);
    DB.last = toc;
end

pause(.005);

tNow = toc;
nSamples = floor(tNow*DB.sRate) - floor(DB.last*DB.sRate);	% # samples to output

DB.last = tNow;

if(nSamples == 0)
    ch = zeros(0,3);
    return;
end

if( DB.move == 0)
    ch = round(2*randn(nSamples,3))+512;   % no gestures, generating random noise
    return;
    
else
    if(DB.burst == 0)
        pos = find(DB.targets == DB.move);
        DB.burst = pos(randi(length(pos)));
        fprintf('\n---\nburst %d selected\n---\n', DB.burst);
    end
    
    last = min(DB.iBurst+nSamples, length(DB.emgs{DB.burst}));
    ch = DB.emgs{DB.burst}( ...
        DB.iBurst+1:last,:)+512;
    
    if(last < length(DB.emgs{DB.burst}))
        DB.iBurst = last;
    else
        % padding with random (eventually 0)
        ch = [ch; round(2*randn(DB.iBurst+nSamples-last,3))+512];
        % movement complete, reset variables
        DB.move = 0;
        DB.burst = 0;
        DB.iBurst = 0;
    end
    
end

end