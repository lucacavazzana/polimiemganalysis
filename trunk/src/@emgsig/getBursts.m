function bursts = getBursts(EMG, varargin)
%GETBURST returns the raw data of the detected bursts
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