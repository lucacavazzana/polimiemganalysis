function [s, a] = ica(emg, a, aOnly)
%ICA    Performs ICA denoising.
%   [S, A] = ICA(SIG , ASTART, AONLY) performs ica denoising, extracting the
%   independent sources and reconstructing the original signal after a
%   dynamical thresholding of the weights. It takes as input the Lx3 signal
%   SIG, where L is the length of the signal, and the (optional) mixing
%   matrix ASTART as initial value. Returns the denoised signal S and the
%   computed matrix A. If AONLY is provided and equal to 1 S is not
%   computed and only a is returned.

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

if nargin < 3
    aOnly = 0;
end

if aOnly    % compute only weights
    if (nargin == 1 || isempty(a))
        [a, ~] = fastica(emg', 'verbose', 'off');
    else
        [a, ~] = fastica(emg', 'verbose', 'off', 'initguess', a);
    end
    
    s=[];
    return;
    
else    % complete analysis
    if (nargin == 1 || isempty(a))
        [s, a, ~] = fastica(emg', 'verbose', 'off');
    else
        [s, a, ~] = fastica(emg', 'verbose', 'off', 'initguess', a);
    end
end

if (size(s,1) == size(emg,2))
    mx = max(abs(a),[],2);
    % for each channel consider only components weighing at least n-percent of
    % the "heaviest" components
    mask = mx(:,ones(1,size(a,2)))*0.6 < abs(a);
    s = ((a.*mask)*s)';
else    % TODO: find a solution to fix singularity into EMG cov matrix
    warning('singularity into emg covariance matrix');
    s = emg;
end

end  