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
function f = extractFeatures(data)

% Wavelet Coefficient + SVD
w = svd(cwt(data,1:5,'morl'));

% integral EMG
iemg = sum(abs(data));
% mean absolute value
mav = iemg/length(data);

f = [iemg mav];
f = cat(2,f,w');

end