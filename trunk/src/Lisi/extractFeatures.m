1 %% ExtractFeatures
2 %  this function extract the features from a given burst
3 %
4 %  Features:
5 %   - IEMG (Integral EMG)
6 %   - MAV (Absolute Mean Value)
7 %   - WAVELET COEFFICIENTS + SVD
8 %
9 % By Giuseppe Lisi for Politecnico di Milano
10 % beppelisi@gmail.com
11 % 8 June 2010
12
13 %% Inputs
14 %  data: is the vector representing a burst
15 %% Outputs
16 % f: is the feature vector.
17 %%
18 function f=extractFeatures(data)
19 iemg=calculateIEMG(data);
20 mav=calculateMAV(data);
21 w=myWavelet(data);
22 f=[iemg mav];
23 f=cat(2,f,w');
24
25 % integral EMG
26 function iemg=calculateIEMG(data)
27 iemg=sum(abs(data));
28
29 % mean absolute value
30 function mav=calculateMAV(data)
31 mav=sum(abs(data))/length(data);
32
33 % Wavelet Coefficient + SVD
34 function w=myWavelet(data)
35
36 % computing the wavelet
37 c = cwt(data,1:5,'morl');
38
39 % reducing the dimensionality of the wavelet coefficient matrix
40 vector=svd(c);
41
42 w=vector;