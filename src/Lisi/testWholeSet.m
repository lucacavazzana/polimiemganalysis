1 %% TestWholeSet
2 % This function is used to test a trained ANN on a whole data
3 %set, contained in the folder np.
4 %
5 % By Giuseppe Lisi for Politecnico di Milano
6 % beppelisi@gmail.com
7 % 8 June 2010
8 %% Inputs
9 %
10 % debug=1: to pause the segmentation phase and plot the figures
11 % of each segemented signal. Debug mode
12 %
13 % np: (name of the person) is the name of the folder in which
14 % are contained the training data.
15 %
16 % plotting=1: to save the figures of the segmented signals
17 % inside the 'img' folder contained inside the np folder. 'img'
18 % is automatically created.
19 %
20 % ch2=1: if the second channel is used.
21 %
22 % ch3=1: if the third channel is used.
23 %
24 % net: is the trained ANN tested with the data contained in np.
25 %% Outputs
26 %
27 % mov: is the vector containing the number of movement
28 % performed during the test phase
29 %
30 % err: is the vector containing the errors during the test
31 % phase
32 %
33 % perf: is the training performance achived
34 %%
35 function [mov,err,perf]=...
36 testWholeSet(debug,np,plotting,ch2,ch3,net)
37 close all;
38 clc;
39
40 % Converts data: txt -> matlab
41 disp('Converting in matlab format')
42 [c mov]=convertAll(debug,np,plotting);
43
44 % finds the size of the output vector
45 movNum=net.outputs{2}.processedSize;
46
47 % extract feature vectors from data contained in the np folder
48 f=takeFeatures(c,debug,plotting,np,ch2,ch3);
49
50 % uses the trained ANN
51 if ¬isempty(f{1,1})A.4. Test xxix
52 [mov,err,perf]=useNN(f,movNum,net);
53 else
54 net=1;
55 mov=1;
56 err=1;
57 perf=1;
58 end
59
60 end