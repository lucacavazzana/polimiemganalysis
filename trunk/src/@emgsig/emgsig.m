classdef emgsig < handle
%EMG class for emg signal analysis

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com
    
    properties (SetAccess = protected)
        
        sRate;                  % sampling frequency
        
        sig = [];               % samples
        low;                    % lowpass sig
        
        nLow;                   % filter coeffs
        dLow;
        nHigh; 
        dHigh;
        
        a = [];
        
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
            
            [EMG.nLow, EMG.dLow] = butter(2, 2 * 2/sRate);  % lowpass @2Hz
            [EMG.nHigh, EMG.dHigh] = butter(2, 10 * 2/sRate, 'high');  % highpass @10Hz
            
        end
        
        function setSignal( EMG, sig )
            %SETSIGNAL sets the signal
            %   replaces the SIG properties with the one provided
            
            EMG.sig = sig;
        end
        
    end     % methods
    
end