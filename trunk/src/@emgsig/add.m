function add(EMG, samples)

    EMG.sig = cat(1, EMG.sig, samples-512);

end