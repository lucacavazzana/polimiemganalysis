function f = splitFilter2(c, acq, saveImgs, i, np, ch2, ch3)
%SPLITFILTER
%   F = SPLITFILTER(C, DEB, ACQ, SAVEIMGS, I, NP, CH2, CH3) takes the Ith
%   signal in the cell matrix C and returns the feature vector F after
%   splitting and filetering.
%   Set ACQ = 1 in acquisition phase (to tell not to extract features. For
%   debugging purposes)
%   If SAVEIMGS is True, saves the graph in the ./NP/img folder.
%
%   CH2 and CH3 tells you to use the relative channels (for debugging)

%	By Giuseppe Lisi for Politecnico di Milano
%	beppelisi@gmail.com
%	8 June 2010


% global DEBUG =1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
%
% acq=1: if the script is used during the acquisition phase

% FIXME: rivedere questa funzione

global DEBUG;

[c1, c2, c3, nsamp] = c{i,:};

% Rectification (FIXME: I guess the board gives you data shifted by 512)
y1 = abs(c1-512);
y2 = abs(c2-512);
y3 = abs(c3-512);

f = [];
f1 = [];
f2 = [];
f3 = [];

%Linear envelope
if(length(y1)~= 1)
    
    %freqCamp = 270; %sampling frequency
    %cutOffFreq = 2; % cutoff frequency of the low-pass filter
    %nyquistFreq = cutOffFreq/(freqCamp/2);
    
    % finding 2nd order lowpass Butterworth filter parameters with 2%
    % cutoff freq (2*cutOff/sampleRate = 4/270)
    [b,a] = butter(2, .0148);
    
    %filt is the envelope of the rectified signal
    y1 = filter(b,a,y1);
    y1 = y1(50:end);
    
    
    y2 = filter(b,a,y2);
    y2 = y2(50:end);
    
    
    y3 = filter(b,a,y3);
    y3 = y3(50:end);
    
    
    % find the edges of each burst
    [firstDiv,secondDiv] = findBurstEMG2(y1,y2,y3,ch2,ch3);
    
    
    %Filtering above 10 Hz
    %cutoffF1=10;
    %nyquistF = cutoffF1/(freqCamp/2);
    [num, den] = butter(2, 0.0741, 'high');
    filtS = filter(num, den, c1);
    filtSign = filtS(50:end);
    
    filtS2=filter(num,den,c2);
    filtSign2=filtS2(50:end);
    
    filtS3=filter(num,den,c3);
    filtSign3=filtS3(50:end);
    
    % the feature extraction is not performed during the
    % acquisition phase.
    if(~acq)
        
        for j=1:length(firstDiv)
            f1(j,:) = extractFeatures(filtSign(firstDiv(j):secondDiv(j)));
        end
        
        
        if ch2
            for j=1:length(firstDiv)
                f2(j,:) = extractFeatures(filtSign2(firstDiv(j):secondDiv(j)));
            end
            
            if ch3
                for j=1:length(firstDiv)
                    f3(j,:) = extractFeatures(filtSign3(firstDiv(j):secondDiv(j)));
                end
            end
        end
        
        if(~isempty(firstDiv))
            f=[f1 f2 f3];
        end
        
    end
    
    if DEBUG % PLOTTING
        
        sum1 = y1(1)*100;
        sum2 = y2(1)*100;
        sum3 = y3(1)*100;
        thr1(1) = sum1;
        thr2(1) = sum2;
        thr3(1) = sum3;
        % computing the 'splitting threshold' in order to plot it
        for ii=2:length(y1)
            sum1=sum1+y1(ii);
            thr1(ii)=sum1/ii;
            sum2=sum2+y2(ii);
            thr2(ii)=sum2/ii;
            sum3=sum3+y3(ii);
            thr3(ii)=sum3/ii;
        end
        
        % Plots the segmentation of the envelope of the first
        % channel.
        figure;
        plot(1:length(y1),y1)
        hold on; grid on;
        plot(1:length(thr1),thr1,'y');
        axis([1 length(y1) 0 150]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
            
        end
        % Plots the segmentation of the envelope of the second
        % channel.
        figure;
        plot(1:length(y2),y2)
        hold on; grid on;
        plot(1:length(thr2),thr2,'y');
        axis([0 length(y2) 0 150]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
            
        end
        
        % Plots the segmentation of the envelope of the third
        % channel.
        figure;
        plot(1:length(y3),y3)
        hold on; grid on;
        plot(1:length(thr3),thr3,'y');
        axis([0 length(y3) 0 150]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
        end
        
        % Plots the segmented and high-pass filtered signal of
        % Channel 1.
        figure;
        plot(1:length(filtSign),filtSign);
        axis([1 length(filtSign) -400 400]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
        end
        
        % Plots the segmented and high-pass filtered signal of
        % Channel 2.
        if ch2
            figure;
            plot(1:length(filtSign2),filtSign2);
            axis([0 length(filtSign2) -400 400]);
            if(~isempty(firstDiv))
                vline(firstDiv,'g','');
                vline(secondDiv,'r','');
            end
        end
        
        % Plots the segmented and high-pass filtered signal of
        % Channel 3.
        if ch3
            figure;
            plot(1:length(filtSign3),filtSign3);
            axis([0 length(filtSign3) -400 400]);
            if(~isempty(firstDiv))
                vline(firstDiv,'g','');
                vline(secondDiv,'r','');
            end
        end
        numberOFMovements=length(firstDiv);
        if(~acq)
            ginput(1);  % waits for figure to close
            close all;
        end
        
        % saving the figures of the fitered and segmented signal
        % into the 'img' folder
        if saveImgs
            if(ispc())
                file2save=[np '/ch1/img/image'...
                    sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
            else
                file2save=[np '\ch1\img\image'...
                    sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
            end
            fig = figure('visible','off');
            plot(1:length(filtSign),filtSign,'b');
            axis([0 length(filtSign) -400 400]);
            if(~isempty(firstDiv))
                vline(firstDiv,'g','');
                vline(secondDiv,'r','');
            end
            saveas(fig,file2save,'eps');
            
            if ch2
                file2save(lenght(np)+4)='2';
                fig = figure('visible','off');
                plot(1:length(filtSign2),filtSign2,'b');
                axis([0 length(filtSign2) -400 400]);
                if(~isempty(firstDiv))
                    vline(firstDiv,'g','');
                    vline(secondDiv,'r','');
                end
                saveas(fig,file2save,'eps');
            end
            
            
            if ch3
                file2save(lenght(np)+4)='3';
                fig = figure('visible','off');
                plot(1:length(filtSign3),filtSign3);
                axis([0 length(filtSign3) -400 400]);
                if(~isempty(firstDiv))
                    vline(firstDiv,'g','');
                    vline(secondDiv,'r','');
                end
                saveas(fig,file2save,'eps');
            end
        end
    end
    
end
end
