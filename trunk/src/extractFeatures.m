function f = extractFeatures(data)
%EXTRACTFEATURES    extracts features from an EMG burst
%  F = EXTRACTFEATURES(D) returns the feature vector F (integral EMG,
%  absolute mean value, wavelet coefficients after SVD) of the burst
%  dataset D.

%  By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%  luca.cavazzana@gmail.com, beppelisi@gmail.com
%  9 November 2011

% starting from the last, so we avoid to rellocate the resulting vector
% after each iteration
for ii = size(data,2):-1:1
    % Wavelet Coefficient + SVD
    asd = cwt(data(:,ii),1:5,'morl');   % FIXME: unsing db?
    w = svd(asd);
    
    % integral EMG
    iemg = sum(abs(data(:,ii)));  % FIXME: if signal already rectified useless to abs
    % adding mean absolute value
    f(7*(ii-1)+1:7*ii,1) = [w; iemg; iemg/size(data,1)];
end

end