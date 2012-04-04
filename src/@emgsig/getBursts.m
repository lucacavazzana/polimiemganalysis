function bursts = getBursts(EMG)
%GETBURST returns the raw data of the detected bursts
%   BURSTS = GETBURSTS() returns a cell-array where each elements contains
%   the samples of the bursts detected by FINDBURSTS.
%
%   See also FINDBURSTS

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

if isempty(EMG.heads)
    bursts = {};
    return;
end

nBursts = size(EMG.heads,2);
bursts = cell(1,nBursts);

for ii = 1:nBursts
    bursts{ii} = EMG.sig(EMG.heads(ii):EMG.tails(ii),:);
end

end