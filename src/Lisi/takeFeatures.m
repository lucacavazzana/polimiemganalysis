1 %% TakeFeatures
2 % This function extracts the feature vectors from all the
3 % signals contained in the np folder.
4 %A.2. Arti?cial Neural Network Training vii
5 % By Giuseppe Lisi for Politecnico di Milano
6 % beppelisi@gmail.com
7 % 8 June 2010
8
9 %% Inputs
10 % c: is the cell array containing all the singals converted in
11 % matlab format.
12 %
13 % debug=1: to pause the segmentation phase and plot the figures
14 % of each segemented signal. Debug mode
15 %
16 % np: (name of the person) is the name of the folder in which
17 % are contained the training data.
18 %
19 % plotting=1: to save the figures of the segmented signals
20 % inside the 'img' folder contained inside the np folder.
21 % 'img' is automatically created.
22 %
23 % ch2=1: if the second channel is used.
24 %
25 % ch3=1: if the third channel is used.
26 %% Outputs
27 % feat: is the cell array containing the feature vectors and
28 % the corresponding target vecors of the signals.
29 %%
30 function feat=takeFeatures(c,debug,plotting,np,ch2,ch3)
31 nsamp=size(c);
32 nsamp=nsamp(1);
33 feat = cell(nsamp, 2);
34
35 for i=1:nsamp
36 % each signal in the cell array is segmented and filtered
37 f=splitFilter(c,debug,0,plotting,i,np,ch2,ch3);
38 feat{i,1}=f;
39 feat{i,2}=c{i,4};
40 end
41
42 end