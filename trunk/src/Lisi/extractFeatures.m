%% ExtractFeatures
%  this function extract the features from a given burst
%
%  Features:
%   - IEMG (Integral EMG)
%   - MAV (Absolute Mean Value)
%   - WAVELET COEFFICIENTS + SVD
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
%  data: is the vector representing a burst
%% Outputs
% f: is the feature vector.
%%
function f=extractFeatures(data)
iemg=calculateIEMG(data);
mav=calculateMAV(data);
w=myWavelet(data);
f=[iemg mav];
f=cat(2,f,w');

% integral EMG
function iemg=calculateIEMG(data)
iemg=sum(abs(data));

% mean absolute value
function mav=calculateMAV(data)
mav=sum(abs(data))/length(data);

% Wavelet Coefficient + SVD
function w=myWavelet(data)

% computing the wavelet
c = cwt(data,1:5,'morl');

% reducing the dimensionality of the wavelet coefficient matrix
vector=svd(c);

w=vector;
