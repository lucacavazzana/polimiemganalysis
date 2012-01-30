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
            
            %  By Luca Cavazzana for Politecnico di Milano
            %  luca.cavazzana@gmail.com
            
            EMG.sRate = sRate;
            
            [EMG.nLow, EMG.dLow] = butter(2, 4/sRate);
            [EMG.nHigh, EMG.dHigh] = butter(2, 20/sRate, 'high');
            
        end
        
        function setSignal( EMG, sig )
            %SETSIGNAL sets the signal
            %   replaces the SIG properties with the one provided
            
            %  By Luca Cavazzana for Politecnico di Milano
            %  luca.cavazzana@gmail.com
            
            EMG.sig = sig;
        end
        
    end     % methods
    
end