1 %% UseNN
2 % this fucntion only uses an already trained ANN, and computes
3 % the performances.
4 % The difference with myNN is that useNN doens't train the ANN.
5 %
6 % By Giuseppe Lisi for Politecnico di Milano
7 % beppelisi@gmail.com
8 % 8 June 2010
9
10 %% Inputs
11 %
12 % feat: is the cell array containing the feature vectors and
13 % the corresponding target vecors of the signals.
14 %
15 % movNum: is the number of movement types on which the ANN is
16 % going to be trained.
17 %
18 % net: is the trained ANN tested with the data contained in
19 % feat.
20 %% Outputs
21 %
22 % movementDone: is the vector containing the number of movement
23 % performed during the test phase
24 %
25 % errorOnTheMovementDone: is the vector containing the errors
26 % during the test phase
27 %
28 % performance: is the training performance achived
29 %%
30 function [movementsDone,errorOnTheMovementsDone,performance]...
31 =useNN(feat,movNum,net)
32
33 [p t vp vt tp tt]=divideData(feat,movNum,0,0,1);
34xxx Appendix A. The Implementation of the Project
35 out = sim(net,tp);
36
37 lout=length(out(1,:));
38
39 for i=1:lout
40 y(:,i)= ismember(out(:,i),max(out(:,i)));
41 end
42
43 error=zeros(1,movNum);
44 elements=zeros(1,movNum);
45 good=0;
46
47
48 ltp=length(tp(1,:));
49 for i=1:ltp
50 if(eq(tt(:,i),y(:,i)))
51 good=good+1;
52 else
53 error(logical(tt(:,i)))=error(logical(tt(:,i)))+1;
54 end
55 elements(logical(tt(:,i)))=elements(logical(tt(:,i)))+1;
56 end
57 movementsDone=elements
58 errorOnTheMovementsDone=error
59
60 performance=good/ltp*100
61 end