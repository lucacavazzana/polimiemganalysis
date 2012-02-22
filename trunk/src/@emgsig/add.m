function len = add(EMG, samples)
%ADD add new samples
%   LEN = ADD(SAMPLES) concatenates new SAMPLES with the ones already
%   stored. Returns the length of the new signal.

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

    EMG.sig = cat(1, EMG.sig, samples-512);
    EMG.low = [];
    
    len = size(EMG.sig,1);
end