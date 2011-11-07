%% DivideData
% Divides the data in 3 training sets: training, validation
% and testing
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010
%% Inputs
%
%   data: data to divide
%
%   movNum: numer of the movement types
%
%   pperf: percentage for the training set
%
%   vperc: percentage for the validation set
%
%   tperc: percentage for the test set

%% Outputs
%   p   training set
%   t   target of the training set
%   vp  validation set
%   vt  target for the validation set
%   tp  test set
%   tt  target of the test set

function [p t vp vt tp tt]=...
    divideData(data,movNum,pperc,vperc,tperc)

f=cell(movNum,1);
targ=cell(movNum,1);
nsamp=size(data);
nsamp=nsamp(1);
base=zeros(1,movNum);

p=[];
t=[];
vp=[];
vt=[];
tp=[];
tt=[];


for i=1:nsamp
    
    f{data{i,2}}=[f{data{i,2}} data{i,1}'];
    nmov=size(data{i,1});
    nmov=nmov(1);
    for j=1:nmov
        base(data{i,2})=1;
        targ{data{i,2}}=[targ{data{i,2}} base'];
        base(data{i,2})=0;
    end
    
end

for i=1:movNum
    train=f{i};
    target=targ{i};
    sz=size(train);
    len=sz(2);
    per=randperm(len);
    traintemp=train(:,per);
    targettemp=target(:,per);
    trlen=floor(len*pperc);
    vallen=floor(len*vperc);
    testlen=floor(len*tperc);
    trlen=trlen+len-(trlen+vallen+testlen);
    
    trainingrange=1:trlen;
    validationrange=trlen+1:trlen+vallen;
    testrange=trlen+vallen+1:trlen+vallen+testlen;
    
    p=[p traintemp(:,trainingrange)];
    t=[t targettemp(:,trainingrange)];
    vp=[vp traintemp(:,validationrange)];
    vt=[vt targettemp(:,validationrange)];
    tp=[tp traintemp(:,testrange)];
    tt=[tt targettemp(:,testrange)];
end

end
