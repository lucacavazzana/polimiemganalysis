function bursts = getBursts(EMG)

nBurts = size(2,EMG.heads);
bursts = cell(1,nBurts);

for ii = 1:nBursts
    bursts{ii} = EMG.sig(EMG.heads(ii):EMG.tails(ii),:);
end

end