function f = splitFilter(c, acq, plotting, i, np, ch2, ch3)
%SPLITFILTER
%   F = SPLITFILTER(C, DEB, ACQ, PLOT, I, NP, CH2, CH3) takes the Ith
%   signal in the cell matrix C and returns the feature vector F after
%   splitting and filetering.
%   If PLOT is True, saves the graph in the ./NP/img folder.
%
%   CH2 and CH3 tells you to use the relative channels (for debugging)

%	By Giuseppe Lisi for Politecnico di Milano
%	beppelisi@gmail.com
%	8 June 2010
%% Inputs
% global DEBUG =1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
%
% acq=1: if the script is used during the acquisition phase

% FIXME: rivedere questa funzione

global DEBUG;

c1 = c{i,1};
c2 = c{i,2};
c3 = c{i,3};
nsamp=c{i,4};

% Rectification
y1=abs(c1-512);
y2=abs(c2-512);
y3=abs(c3-512);

f=[];
f1=[];
f2=[];
f3=[];

%Linear envelope
if(length(y1)~= 1)
    
    freqCamp=270; %sampling frequency
    cutOffFreq=2; %cutoff frequency of the low-pass filter
    nyquistFreq=cutOffFreq/(freqCamp/2); % <- FIXME serio? ricalcolare tutto ogni volta?
    [b,a]=butter(2,nyquistFreq);
    
    %filt is the envelope of the rectified signal
    filt1=filter(b,a,y1);
    filt1=filt1(50:length(filt1)); % <- FIXME usare direttamente gli indici, invece che perdere tempo riallocando?
    
    
    filt2=filter(b,a,y2);
    filt2=filt2(50:length(filt2));
    
    
    filt3=filter(b,a,y3);
    filt3=filt3(50:length(filt3));
    
    
    
    % find the edges of each burst
    [firstDiv,secondDiv]...
        =findBurstEMG(filt1,filt2,filt3,ch2,ch3);
    
    
    %Filtering above 10 Hz
    cutoffF1=10;
    nyquistF=cutoffF1/(freqCamp/2); % FIXME OMG AGAIN!
    [num,den] = butter(2,nyquistF,'high');
    filtS=filter(num,den,c1);
    filtSign=filtS(50:length(filtS));
    
    filtS2=filter(num,den,c2);
    filtSign2=filtS2(50:length(filtS2));
    
    filtS3=filter(num,den,c3);
    filtSign3=filtS3(50:length(filtS3));
    
    % the feature extraction is not performed during the
    % acquisition phase.
    if(~acq)
        
        for j=1:length(firstDiv)
            f1(j,:)=...
                extractFeatures(filtSign(firstDiv(j):secondDiv(j)));
        end
        
        
        if ch2
            for j=1:length(firstDiv)
                f2(j,:)=...
                    extractFeatures(filtSign2(firstDiv(j):secondDiv(j)));
            end
        end
        
        if ch3
            for j=1:length(firstDiv)
                f3(j,:)=...
                    extractFeatures(filtSign3(firstDiv(j):secondDiv(j)));
            end
        end
        
        if(~isempty(firstDiv))
            
            f=[f1 f2 f3];
        end
        
    end

    sum1=filt1(1)*100;
    sum2=filt2(1)*100;
    sum3=filt3(1)*100;
    thr1(1)=sum1;
    thr2(1)=sum2;
    thr3(1)=sum3;
    % computing the 'splitting threshold' in order to plot it
    for ii=2:length(filt1)
        sum1=sum1+filt1(ii);
        thr1(ii)=sum1/ii;
        sum2=sum2+filt2(ii);
        thr2(ii)=sum2/ii;
        sum3=sum3+filt3(ii);
        thr3(ii)=sum3/ii;
    end
    
    
    
    if DEBUG
        % Plots the segmentation of the envelope of the first
        % channel.
        figure;
        plot(1:length(filt1),filt1)
        hold on; grid on;
        plot(1:length(thr1),thr1,'y');
        axis([1 length(filt1) 0 150]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
            
        end
        % Plots the segmentation of the envelope of the second
        % channel.
        figure;
        plot(1:length(filt2),filt2)
        hold on; grid on;
        plot(1:length(thr2),thr2,'y');
        axis([0 length(filt2) 0 150]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
            
        end
        
        % Plots the segmentation of the envelope of the third
        % channel.
        figure;
        plot(1:length(filt3),filt3)
        hold on; grid on;
        plot(1:length(thr3),thr3,'y');
        axis([0 length(filt3) 0 150]);
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
        
        
    end
    
    % saving the figures of the fitered and segmented signal
    % into the 'img' folder
    if plotting
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
