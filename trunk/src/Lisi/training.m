1 %% Training
2 % This function is used to train a network on data contained
3 % inside a folder. This data are the EMG signals acquired
4 % from a single person using three different channels.
5 %
6 % By Giuseppe Lisi for Politecnico di Milano
7 % beppelisi@gmail.com
8 % 8 June 2010
9
10 %% Inputs
11 % debug=1: to pause the segmentation phase and plot the
12 % figures of each segemented signal. Debug mode
13 %
14 % np: (name of the person) is the name of the folder in
15 % which are contained the training data.
16 %
17 % plotting=1: to save the figures of the segmented
18 % signals inside the 'img' folder contained inside the np
19 % folder. 'img' is automatically created.
20 %
21 % ch2=1: if the second channel is used.
22 %
23 % ch3=1: if the third channel is used.
24 %% Outputs
25 %
26 % net: is the trained artificial neural network
27 %
28 % mov: is the vector containing the number of movement
29 % performed during the test phase
30 %
31 % err: is the vector containing the errors during the test
32 % phase
33 %iv Appendix A. The Implementation of the Project
34 % perf: is the training performance achived
35 %%
36 function [net,mov,err,perf]=training(debug,np,plotting,ch2,ch3)
37 close all;
38 clc;
39
40 % converts data: txt -> matlab
41 disp('Converting in matlab format')
42 [c movNum]=convertAll(debug,np,plotting);
43
44 % extracts the feature vectors from all the signals contained
45 % in the np folder.
46 f=takeFeatures(c,debug,plotting,np,ch2,ch3);
47
48 if ¬isempty(f{1,1})
49 %trains an artificial neural network
50 [net,mov,err,perf]=myNN(f,movNum);
51 else
52 net=1;
53 mov=1;
54 err=1;
55 perf=1;
56 end
57
58
59 end