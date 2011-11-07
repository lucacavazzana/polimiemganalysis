1 %% Convert All
2 % This function converts all the txt files into the matlab
3 % format.
4 % Future users have to replace
5 % /Users/giuseppelisi/University/...
6 %   Thesis/Matlab/FilesNewEmg/serial/
7 % with their own favourite folder
8 % Remember that this code is run on a uinix based machine,
9 % therefore it is
10 % important to modify some OS oriented commands.
11 %
12 % By Giuseppe Lisi for Politecnico di Milano
13 % beppelisi@gmail.com
14 % 8 June 2010
15
16 %% Inputs
17 % debug=1: to pause the segmentation phase and plot the figuresA.2. Arti?cial Neural Network Training v
18 % of each segemented signal. Debug mode
19 %
20 % np: is the name of the folder in which are contained the
21 % training data.
22 %
23 % plotting=1: to save the figures of the segmented signals
24 % inside the 'img' folder contained inside the np folder. 'img'
25 % is automatically created.
26 %
27 %% Outputs
28 % c: is the cell array containing the converted data.
29 %%
30 function [c movNumber]=convertAll(debug,np,plotting)
31
32 file=['/Users/giuseppelisi/University/Thesis/'...
33 'Matlab/FilesNewEmg/serial/' np '/ch1/*.txt'];
34 d = dir(file);
35
36 fileIndex = find(¬[d.isdir]);
37 len=length(fileIndex);
38 c = cell(len, 4);
39 movNumber=1;
40 movId=[];
41 movKey=[];
42
43
44
45 for i = 1:length(fileIndex)
46
47 fileName = d(fileIndex(i)).name;
48 movement=sscanf(fileName,'%d%*s');
49 f=['/Users/giuseppelisi/University/Thesis/Matlab/'...
50 'FilesNewEmg/serial/' np '/ch1/' fileName];
51 data=convertFile2MAT(f);
52 c{i,1}=data;
53 f=['/Users/giuseppelisi/University/Thesis/Matlab/'...
54 'FilesNewEmg/serial/' np '/ch2/' fileName];
55 data=convertFile2MAT(f);
56 c{i,2}=data;
57 f=['/Users/giuseppelisi/University/Thesis/Matlab/'...
58 'FilesNewEmg/serial/' np '/ch3/' fileName];
59 data=convertFile2MAT(f);
60 c{i,3}=data;
61
62 pos=find(movId==movement);
63 if(isempty(pos))
64 % here the movement IDs are mapped into a key ID in order to
65 % make it possible to use data ordered whith different IDs
66 % inside the foldervi Appendix A. The Implementation of the Project
67 movId=[movId movement];
68 movKey=[movKey movNumber];
69 c{i,4}=movNumber;
70 movNumber=movNumber+1;
71 else
72 c{i,4}=movKey(pos);
73 end
74 end
75 movId
76 movKey
77 movNumber=movNumber-1;
78
79 end