%% MyNN
% This function trains and simulates an artificial neural
% network
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
% feat: is the cell array containing the feature vectors
% and the
% corresponding target vecors of the signals.
%
% movNum: is the number of movement types (7 in this thesis)

%% Outputs
%
% net: is the trained artificial neural network
%
% movementDone: is the vector containing the number of movement
% performed during the
% test phase
%
% errorOnTheMovementDone: is the vector containing the errors
% during the test phase
%
% performance: is the training performance achived
%%
function ...
    [net,movementsDone,errorOnTheMovementsDone,performance]...
    =myNN(feat,movNum)

% divide the incoming data into Training, Validation and Test
% sets.
[p t vp vt tp tt]=divideData(feat,movNum,3/5,1/5,1/5);

% create the ANN
net=newff(p,t,35);

% modify some network parameters (values found empirically)
v.P=vp;
v.T=vt;
net.trainParam.mu=0.9;
net.trainParam.mu_dec=0.8;
net.trainParam.mu_inc=1.5;
net.trainParam.goal=0.001;

% train the ANN
net = train(net,p,t,{},{},v);

% simulate the network
out = sim(net,tp);


% computing the performances
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
