1 %% MyNN
2 % This function trains and simulates an artificial neural
3 % network
4 %
5 % By Giuseppe Lisi for Politecnico di Milano
6 % beppelisi@gmail.com
7 % 8 June 2010
8
9 %% Inputs
10 % feat: is the cell array containing the feature vectors
11 % and the
12 % corresponding target vecors of the signals.
13 %
14 % movNum: is the number of movement types (7 in this thesis)
15
16 %% Outputs
17 %
18 % net: is the trained artificial neural network
19 %
20 % movementDone: is the vector containing the number of movement
21 % performed during the
22 % test phase
23 %
24 % errorOnTheMovementDone: is the vector containing the errors
25 % during the test phase
26 %
27 % performance: is the training performance achived
28 %%
29 function ...
30 [net,movementsDone,errorOnTheMovementsDone,performance]...
31 =myNN(feat,movNum)
32
33 % divide the incoming data into Training, Validation and Test
34 % sets.
35 [p t vp vt tp tt]=divideData(feat,movNum,3/5,1/5,1/5);
36
37 % create the ANN
38 net=newff(p,t,35);
39
40 % modify some network parameters (values found empirically)
41 v.P=vp;
42 v.T=vt;
43 net.trainParam.mu=0.9;
44 net.trainParam.mu dec=0.8;
45 net.trainParam.mu inc=1.5;
46 net.trainParam.goal=0.001;
47
48 % train the ANN
49 net = train(net,p,t,{},{},v);
50
51 % simulate the network
52 out = sim(net,tp);
53
54
55 % computing the performances
56 lout=length(out(1,:));
57 for i=1:lout
58 y(:,i)= ismember(out(:,i),max(out(:,i)));
59 end
60
61 error=zeros(1,movNum);
62 elements=zeros(1,movNum);
63 good=0;
64
65
66 ltp=length(tp(1,:));
67 for i=1:ltp
68 if(eq(tt(:,i),y(:,i)))
69 good=good+1;
70 else
71 error(logical(tt(:,i)))=error(logical(tt(:,i)))+1;
72 end
73 elements(logical(tt(:,i)))=elements(logical(tt(:,i)))+1;
74 end
75 movementsDone=elements
76 errorOnTheMovementsDone=error
77
78 performance=good/ltp*100
79 end