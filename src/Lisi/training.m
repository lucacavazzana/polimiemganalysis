%% Training
% This function is used to train a network on data contained
% inside a folder. This data are the EMG signals acquired
% from a single person using three different channels.
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
% debug=1: to pause the segmentation phase and plot the
% figures of each segemented signal. Debug mode
%
% np: (name of the person) is the name of the folder in
% which are contained the training data.
%
% plotting=1: to save the figures of the segmented
% signals inside the 'img' folder contained inside the np
% folder. 'img' is automatically created.
%
% ch2=1: if the second channel is used.
%
% ch3=1: if the third channel is used.
%% Outputs
%
% net: is the trained artificial neural network
%
% mov: is the vector containing the number of movement
% performed during the test phase
%
% err: is the vector containing the errors during the test
% phase
%iv Appendix A. The Implementation of the Project
% perf: is the training performance achived
%%
function [net,mov,err,perf]=training(debug,np,plotting,ch2,ch3)
close all;
clc;

% converts data: txt -> matlab
disp('Converting in matlab format')
[c movNum]=convertAll(debug,np,plotting);

% extracts the feature vectors from all the signals contained
% in the np folder.
f=takeFeatures(c,debug,plotting,np,ch2,ch3);

if ~isempty(f{1,1})
    %trains an artificial neural network
    [net,mov,err,perf]=myNN(f,movNum);
else
    net=1;
    mov=1;
    err=1;
    perf=1;
end


end
