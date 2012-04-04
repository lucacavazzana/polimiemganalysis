function f = extractFeatures(data, scales, yWAV, xWAV)
%EXTRACTFEATURES    extracts features from an EMG burst
%   F = EXTRACTFEATURES(D, SCALES YWAV, XWAV) returns the feature vector F
%   (integral EMG, absolute mean value, wavelet coefficients after SVD) of
%   the burst dataset D. YWAV and XWAV are the values of the mother wavelet
%   obtained with INTWAVE, SCALES are the scaling coefficients.

%   By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%   luca.cavazzana@gmail.com, beppelisi@gmail.com

sz = size(scales,2)+2;  % size feats: #sv + iEmg + meanEmg

% starting from the last, so we avoid to rellocate the resulting vector
% after each iteration
for cc = size(data,2):-1:1
    % Wavelet Coefficients + SVD    
    asd = myCwt(data, scales, yWAV, xWAV);
    
    % cutting first element (dirty because highpass filtering)
    w = svd(asd(:,20:end), 0);
    
    
    % integral EMG
    iemg = sum(abs(data(:,cc))); % FIXME: if signal already rectified useless to abs
    % adding mean absolute value
    f(sz*(cc-1)+1:sz*cc, 1) = [w; iemg; iemg/size(data,1)];
    
end

end