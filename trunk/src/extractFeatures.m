function f = extractFeatures(data, yWAV, xWAV)
%EXTRACTFEATURES extracts features from an EMG burst
%   F = EXTRACTFEATURES(D, YWAV, XWAV) returns the feature vector F
%   (integral EMG, absolute mean value, wavelet coefficients after SVD) of
%   the burst dataset D. YWAV and XWAV are the values of the mother wavelet
%   obtained with INTWAVE.

%   By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%   luca.cavazzana@gmail.com, beppelisi@gmail.com

CODE = 0; % 1 new, 0 old one (Lisi's)

if(CODE==1)
    scales = 1.5:6.5;
else
    scales = 1:5;
end
sz = size(scales,2)+2;  % size feats: #sv + iEmg + meanEmg

% starting from the last, so we avoid to rellocate the resulting vector
% after each iteration
for cc = size(data,2):-1:1
    % Wavelet Coefficients + SVD
    
    
    if(CODE == 1) % NEW WAVELET
        
        % db is better than morl (has a lower mse reconstructing the signal).
        % Empirically db4 and db8 are the best.
        % Scales are tuned to fit our signal with db4
        asd = myCwt(data, scales, yWAV, xWAV);
        
        % cutting first element (dirty because lowpass filtering)
        w = svd(asd(:,20:end), 0);
        
    else    % Lisi
        
        % cutting first element (dirty because lowpass filtering)
        asd = cwt(data(20:end,cc), scales, 'morl');
        w = svd(asd);
    end
    
    % integral EMG
    iemg = sum(abs(data(:,cc))); % FIXME: if signal already rectified useless to abs
    % adding mean absolute value
    f(sz*(cc-1)+1:sz*cc, 1) = [w; iemg; iemg/size(data,1)];
    
end

end