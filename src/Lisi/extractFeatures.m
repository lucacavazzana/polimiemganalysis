function f = extractFeatures(data)
%EXTRACTFEATURES    extracts features from an EMG burst
%  F = EXTRACTFEATURES(D) returns the feature vector F (integral EMG,
%  absolute mean value, wavelet coefficients after SVD) of the burst
%  dataset D.

%  By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%  luca.cavazzana@gmail.com, beppelisi@gmail.com
%  9 November 2011

% Wavelet Coefficient + SVD
w = svd(cwt(data,1:5,'morl'));

% integral EMG
iemg = sum(abs(data));  % FIXME: if signal already rectified useless to abs
% adding mean absolute value
f = [w; iemg; iemg/length(data);];

end