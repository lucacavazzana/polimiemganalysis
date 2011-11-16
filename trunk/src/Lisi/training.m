function [net,mov,err,perf]=training(np,plotting,ch2,ch3)
%TRAINING   Trains a NN for gesture recognition
%	This function is used to train a network on data contained
% inside a folder. This data are the EMG signals acquired
% from a single person using three different channels.
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
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
%
% perf: is the training performance achived
%%
close all;
clc;

% converts data: txt -> matlab
[c movNum] = convertAll(np);

% extracts the feature vectors from all the signals contained
% in the np folder.
f = takeFeatures(c ,plotting, np, ch2, ch3);

if ~isempty(f{1,1})
    %trains an artificial neural network
    [net, mov, err, perf] = myNN(f, movNum);
else
    disp(' - WARNING: could not train the NN');
    net=1;
    mov=1;
    err=1;
    perf=1;
end


end
