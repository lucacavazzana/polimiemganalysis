function testNet(debug,np,movNum,ch2,ch3,rep)
%TESTNET
% this function runs many times the training of different ANN,
% on different commutations of the training data. This is done
% in order to understand the average performances of the
% network.
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
%
% debug=1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
%
% np: (name of the person) is the name of the folder in which
% are contained the training data.
%
% movNum: is the number of movement types on which the ANN is
% going to betrained
%
% ch2=1: if the second channel is used.
%
% ch3=1: if the third channel is used.
%
% rep: number of training repetitions.

%% Outputs
%%
%rep number of repetition
movSum=zeros(1,movNum);
errSum=zeros(1,movNum);
perform=0;


for i=1:rep
    
    [net,mov,err,perf]=training(debug,np,0,ch2,ch3);
    movSum=movSum+mov;
    errSum=errSum+err;
    perform=perform+perf;
    
end

movSum
errSum
stat=perform/rep
end
