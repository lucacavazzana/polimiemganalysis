1 %% TestNet
2 % this function runs many times the training of different ANN,
3 % on different commutations of the training data. This is done
4 % in order to understand the average performances of the
5 % network.
6 %
7 % By Giuseppe Lisi for Politecnico di Milano
8 % beppelisi@gmail.comA.4. Test xxvii
9 % 8 June 2010
10
11 %% Inputs
12 %
13 % debug=1: to pause the segmentation phase and plot the figures
14 % of each segemented signal. Debug mode
15 %
16 % np: (name of the person) is the name of the folder in which
17 % are contained the training data.
18 %
19 % movNum: is the number of movement types on which the ANN is
20 % going to betrained
21 %
22 % ch2=1: if the second channel is used.
23 %
24 % ch3=1: if the third channel is used.
25 %
26 % rep: number of training repetitions.
27
28 %% Outputs
29 %%
30 function testNet(debug,np,movNum,ch2,ch3,rep)
31 %rep number of repetition
32 movSum=zeros(1,movNum);
33 errSum=zeros(1,movNum);
34 perform=0;
35
36
37 for i=1:rep
38
39 [net,mov,err,perf]=training(debug,np,0,ch2,ch3);
40 movSum=movSum+mov;
41 errSum=errSum+err;
42 perform=perform+perf;
43
44 end
45
46 movSum
47 errSum
48 stat=perform/rep
49 end