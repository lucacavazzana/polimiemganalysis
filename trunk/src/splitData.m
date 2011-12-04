function [trSet, valSet, testSet] = splitData(data, pTrain, pVal)
%SPLITDATA  split emg sets into training, validation and test
%  [TRSET VALSET TESTSET] = SPLITDATA(DATA, PTRAIN, PVAL) given the dataset
%  DATA returns the the indexes, for each gesture, of the training set
%  TRSET, validation set VALSET and test set TESTSET according to the
%  percentage PTRAIN and PVAL (test percentage is what is left).

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

trSet = cell(length(data),1);
valSet = cell(length(data),1);
testSet = cell(length(data),1);

% TODO: add error checking
for gg=1:length(data)
     [trSet{gg}, valSet{gg}, testSet{gg}] = dividerand(length(data{gg}), pTrain, pVal, 1-pTrain-pVal);
end

end