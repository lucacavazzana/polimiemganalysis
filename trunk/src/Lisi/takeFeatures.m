%% TakeFeatures
% This function extracts the feature vectors from all the
% signals contained in the np folder.
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
% c: is the cell array containing all the singals converted in
% matlab format.
%
% debug=1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
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
%% Outputs
% feat: is the cell array containing the feature vectors and
% the corresponding target vecors of the signals.
%%
function feat=takeFeatures(c,debug,plotting,np,ch2,ch3)
nsamp=size(c,1);
feat = cell(nsamp, 2);

for i=1:nsamp
    % each signal in the cell array is segmented and filtered
    f=splitFilter(c,debug,0,plotting,i,np,ch2,ch3);
    feat{i,1}=f;
    feat{i,2}=c{i,4};
end

end
