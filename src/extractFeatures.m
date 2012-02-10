function f = extractFeatures(data)
%EXTRACTFEATURES    extracts features from an EMG burst
%  F = EXTRACTFEATURES(D) returns the feature vector F (integral EMG,
%  absolute mean value, wavelet coefficients after SVD) of the burst
%  dataset D.

%   By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%   luca.cavazzana@gmail.com, beppelisi@gmail.com

% starting from the last, so we avoid to rellocate the resulting vector
% after each iteration
for cc = size(data,2):-1:1
    % Wavelet Coefficients + SVD
    asd = cwt(data(20:end,cc),1:5,'db4');   % cutting first element (dirty because lowpass filtering)
    % db is better than morl (has a lower mse reconstructing the signal).
    % Powers of 2 are better into reconstruction, but computation increases
    % with the level. Empirically db4 and db8 are the best.
    
    w = svd(asd);
    
    % integral EMG
    iemg = sum(abs(data(:,cc)));  % FIXME: if signal already rectified useless to abs
    % adding mean absolute value
    f(7*(cc-1)+1:7*cc,1) = [w; iemg; iemg/size(data,1)];

end

end