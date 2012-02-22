classdef emgsig < handle
%EMG class for emg signal analysis
%   EMGSIG(SRATE) returns an object for signal analysis. SRATE is the
%   sample rate of the acquisition.
%
%   See also ADD, CLEARSIGNAL, EXTRACTFEATURES, FINDBURSTS, GETBURSTS,
%   PLOTBURST, PLOTSIGNAL

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com
    
    properties (SetAccess = protected)
        
        sRate;                  % sampling frequency
        
        sig = [];               % samples
        low;                    % lowpass sig
        
        nLow;                   % filter coeffs
        dLow;
        nHigh; 
        dHigh;
        
        a = [];                 % ica weights
        
        yWAV;                   % wavelet
        xWAV;
        
        heads = [];
        tails = [];
        ch = [];
        
    end     % properties
    
    methods
        
        function EMG = emgsig(sRate)
            %EMG creates an emg object
            %   EMG(SRATE) creates an EMG object for emg analysis. SRATE is
            %   the sample rate of the signal.
            
            EMG.sRate = sRate;
            
            % sRate/2 is the Nyquist frequency
%             [EMG.nLow, EMG.dLow] = butter(2, 2 * 2/sRate);  % lowpass @2Hz
            [EMG.nLow, EMG.dLow] = butter(2, [0.1 2] * 2/sRate);  % bandpass @[.1 2]Hz. .1 is to remove mean value
            [EMG.nHigh, EMG.dHigh] = butter(2, 10 * 2/sRate, 'high');  % highpass @10Hz
            
            % building wavelet
            [EMG.yWAV, EMG.xWAV] = intwave('db4',10);
            
        end
        
        function len = setSignal( EMG, sig )
            %SETSIGNAL sets the signal
            %   replaces the SIG properties with the one provided. Returns
            %   signal length.
            
            EMG.sig = sig;
            EMG.low = [];
            
            len = size(EMG.sig,1);
        end
        
    end     % methods
    
end