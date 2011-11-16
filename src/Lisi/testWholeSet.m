function [mov,err,perf] = testWholeSet(np, plotting, ch2, ch3, net)
%TESTWHOLESET
% This function is used to test a trained ANN on a whole data
% set, contained in the folder np.
%
%	By Giuseppe Lisi for Politecnico di Milano
%	beppelisi@gmail.com
%	8 June 2010
%% Inputs
%
% np: (name of the person) is the name of the folder in which
% are contained the training data.
%
% plotting=1: to save the figures of the segmented signals
% inside the 'img' folder contained inside the np folder. 'img'
% is automatically created.
%
% ch2=1: if the second channel is used.
%
% ch3=1: if the third channel is used.
%
% net: is the trained ANN tested with the data contained in np.
%% Outputs
%
% mov: is the vector containing the number of movement
% performed during the test phase
%
% err: is the vector containing the errors during the test
% phase
%
% perf: is the training performance achived
%%
close all;
clc;

% Converts data: txt -> matlab
disp('Converting in matlab format');
c = convertAll(np,plotting);

% finds the size of the output vector
movNum=net.outputs{2}.processedSize;

% extract feature vectors from data contained in the np folder
f=takeFeatures(c,plotting,np,ch2,ch3);

% uses the trained ANN
if ~isempty(f{1,1})
    [mov,err,perf]=useNN(f,movNum,net);
else
    net=1;
    mov=1;
    err=1;
    perf=1;
end

end
