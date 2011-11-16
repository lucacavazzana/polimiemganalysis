function [net, movDone, errOnMov, perf] = ...
    myNN(feat ,movNum)
%MYNN   Trains a NN for gestures recognition
%   [NET, MOVDONE, ERRONMOV, PERF] = MYNN(F, MOVNUM) trains and simulates
%   an artificial neural network, where F are the features and MOVNUM the
%   number of movements. Returns the trained net NET and the number of
%   movements performed during the test phase MOVDONE, the relative error
%   ERRONMOV and the performance evaluation PERF.

%	By Giuseppe Lisi for Politecnico di Milano
%	beppelisi@gmail.com
%	8 June 2010

% divide the incoming data into Training, Validation and Test
% sets.
[p t vp vt tp tt] = divideData(feat,movNum,3/5,1/5,1/5);

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

% no need to compute performances if not asked for
if(nargout == 1)
    return;
end

% FIXME: da qui in poi ridondante con useNN

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
movDone=elements
errOnMov=error

perf=good/ltp*100
end
