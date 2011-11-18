function feats = takeFeatures(c,plotting,np,ch2,ch3)
%TAKEFEATURES   Features extraction.
%	This function extracts the feature vectors from all the
%	signals contained in the np folder.
%
%	By Giuseppe Lisi for Politecnico di Milano
%	beppelisi@gmail.com
%	8 June 2010

% Inputs
% c: is the cell array containing all the singals converted in
% matlab format.
%
% np: (name of the person) is the name of the folder in which
% are contained the training data.
%
% plotting=1: to save the figures of the segmented signals
% inside the 'img' folder contained inside the np folder.
% 'img' is automatically created.
%
% ch2=1: if the second channel is used.
%
% ch3=1: if the third channel is used.

% Outputs
% feat: is the cell array containing the feature vectors and
% the corresponding target vecors of the signals.

nsamp = size(c,1);
feats = cell(nsamp, 2);

for i = 1:nsamp
    % each signal in the cell array is segmented and filtered
    f = splitFilter(c,0,plotting,i,np,ch2,ch3);
    feats{i,1} = f;
    feats{i,2} = c{i,4};
end

end
