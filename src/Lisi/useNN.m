%% UseNN
% this fucntion only uses an already trained ANN, and computes
% the performances.
% The difference with myNN is that useNN doens't train the ANN.
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
%
% feat: is the cell array containing the feature vectors and
% the corresponding target vecors of the signals.
%
% movNum: is the number of movement types on which the ANN is
% going to be trained.
%
% net: is the trained ANN tested with the data contained in
% feat.
%% Outputs
%
% movementDone: is the vector containing the number of movement
% performed during the test phase
%
% errorOnTheMovementDone: is the vector containing the errors
% during the test phase
%
% performance: is the training performance achived
%%
function [movementsDone,errorOnTheMovementsDone,performance]...
    =useNN(feat,movNum,net)

[p t vp vt tp tt]=divideData(feat,movNum,0,0,1);
xxx Appendix A. The Implementation of the Project
out = sim(net,tp);

lout=length(out(1,:));

for i=1:lout
    y(:,i)= ismember(out(:,i),max(out(:,i)));
end

error=zeros(1,movNum);
elements=zeros(1,movNum);
good=0;


ltp=length(tp(1,:));
for i=1:ltp
    if(eq(tt(:,i),y(:,i)))
        good=good+1;
    else
        error(logical(tt(:,i)))=error(logical(tt(:,i)))+1;
    end
    elements(logical(tt(:,i)))=elements(logical(tt(:,i)))+1;
end
movementsDone=elements
errorOnTheMovementsDone=error

performance=good/ltp*100
end