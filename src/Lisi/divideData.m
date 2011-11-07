1 %% DivideData
2 % Divides the data in 3 training sets: training, validation
3 % and testing
4 %
5 % By Giuseppe Lisi for Politecnico di Milano
6 % beppelisi@gmail.com
7 % 8 June 2010
8 %% Inputs
9 %
10 %   data: data to divide
11 %
12 %   movNum: numer of the movement types
13 %
14 %   pperf: percentage for the training set
15 %
16 %   vperc: percentage for the validation set
17 %
18 %   tperc: percentage for the test set
19
20 %% Outputs
21 %   p   training set
22 %   t   target of the training set
23 %   vp  validation set
24 %   vt  target for the validation set
25 %   tp  test set
26 %   tt  target of the test set
27
28 %%xxii Appendix A. The Implementation of the Project
29 function [p t vp vt tp tt]=...
30 divideData(data,movNum,pperc,vperc,tperc)
31
32 f=cell(movNum,1);
33 targ=cell(movNum,1);
34 nsamp=size(data);
35 nsamp=nsamp(1);
36 base=zeros(1,movNum);
37
38 p=[];
39 t=[];
40 vp=[];
41 vt=[];
42 tp=[];
43 tt=[];
44
45
46 for i=1:nsamp
47
48 f{data{i,2}}=[f{data{i,2}} data{i,1}'];
49 nmov=size(data{i,1});
50 nmov=nmov(1);
51 for j=1:nmov
52 base(data{i,2})=1;
53 targ{data{i,2}}=[targ{data{i,2}} base'];
54 base(data{i,2})=0;
55 end
56
57 end
58
59 for i=1:movNum
60 train=f{i};
61 target=targ{i};
62 sz=size(train);
63 len=sz(2);
64 per=randperm(len);
65 traintemp=train(:,per);
66 targettemp=target(:,per);
67 trlen=floor(len*pperc);
68 vallen=floor(len*vperc);
69 testlen=floor(len*tperc);
70 trlen=trlen+len-(trlen+vallen+testlen);
71
72 trainingrange=1:trlen;
73 validationrange=trlen+1:trlen+vallen;
74 testrange=trlen+vallen+1:trlen+vallen+testlen;
75
76 p=[p traintemp(:,trainingrange)];
77 t=[t targettemp(:,trainingrange)];
78 vp=[vp traintemp(:,validationrange)];
79 vt=[vt targettemp(:,validationrange)];
80 tp=[tp traintemp(:,testrange)];
81 tt=[tt targettemp(:,testrange)];
82 end
83
84 end