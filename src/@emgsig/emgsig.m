classdef emgsig < handle
%EMG class for emg signal analysis
%   EMGSIG(SRATE) returns an object for signal analysis. SRATE is the
%   sample rate of the acquisition.
%
%   See also ADD, CLEARSIGNAL, EXTRACTFEATURES, FINDBURSTS, GETBURSTS,
%   PLOTSIGNAL

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
            [EMG.nLow, EMG.dLow] = butter(2, 2 * 2/sRate);  % lowpass @2Hz
            [EMG.nHigh, EMG.dHigh] = butter(2, 10 * 2/sRate, 'high');  % highpass @10Hz
            
            % building wavelet
            [EMG.yWAV, EMG.xWAV] = intwave('db4',10);
            
        end
        
        function setSignal( EMG, sig )
            %SETSIGNAL sets the signal
            %   replaces the SIG properties with the one provided
            
            EMG.sig = sig;
        end
        
    end     % methods
    
end