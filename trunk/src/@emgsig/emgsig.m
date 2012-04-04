classdef emgsig < handle
%EMG class for emg signal analysis
%
%   EMGSIG encapsulates the EMG signal and provides the methods for burst
%   detection and feature extraction.
%
%   See also ADD, CLEARSIGNAL, EXTRACTFEATURES, FINDBURSTS, GETBURSTS,
%   PLOTBURST, PLOTSIGNAL

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com
    
    properties (SetAccess = protected)
        
        sRate;                  % sampling frequency
        
        sig = [];               % signal samples
        low;                    % lowpass signal
        
        nLow;                   % lowpass zeros
        dLow;                   % lowpass poles
        nHigh;                  % highpass zeros
        dHigh;                  % highpass poles
        
        a = [];                 % ica weights
        
        yWAV;                   % wavelet
        xWAV;
        scales;                 % wavelet scales
        
        heads = [];             % detected bursts' head
        tails = [];             % detected bursts' tail
        ch = [];                % detected bursts' dominant channel
        
    end     % properties
    
    methods
        
        function EMG = emgsig(sRate, varargin)
            %EMG creates an emg object
            %   EMG(SRATE) creates an EMG object for emg analysis. SRATE is
            %   the sample rate of the signal.
            
            
            LISI = 0;
            for ii = 1:length(varargin)
                switch varargin{ii}
                    case 'lisi'     % using previous wavelets
                        disp('using Lisi''s wavelets');
                        LISI = 1;
                end
            end
            
            
            EMG.sRate = sRate;
            
            % sRate/2 is the Nyquist frequency
            % [EMG.nLow, EMG.dLow] = butter(2, 2 * 2/sRate);  % lowpass @2Hz
            [EMG.nLow, EMG.dLow] = butter(2, [0.1 2] * 2/sRate);  % bandpass @[.1 2]Hz. .1 is to remove mean value
            [EMG.nHigh, EMG.dHigh] = butter(2, 10 * 2/sRate, 'high');  % highpass @10Hz
            
            % building wavelet
            [EMG.yWAV, EMG.xWAV] = intwave('db4',10);
            EMG.scales = 1.5:6.5;
            

            % LISI'S VERSION:
            if(LISI)
                [EMG.yWAV, EMG.xWAV] = intwave('morl',10);
                EMG.scales = 1:5;
            end
            
        end
        
        function len = setSignal( EMG, sig )
            %SETSIGNAL sets the signal
            %	LEN = ES.setSignal(SIG) replaces the EMG signal with the
            %   one provided with SIG. Returns signal's length LEN.
            
            EMG.sig = sig;
            EMG.low = [];
            
            EMG.a = [];
            EMG.heads = [];
            EMG.tails = [];
            EMG.ch = [];
            
            len = size(EMG.sig,1);
        end
        
    end     % methods
    
end