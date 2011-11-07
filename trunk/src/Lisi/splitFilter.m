%% Split Filter
% This script is used to split the incoming signal and to
% filter it.
%
% By Giuseppe Lisi for Politecnico di Milanoviii Appendix A. The Implementation of the Project
% beppelisi@gmail.com
% 8 June 2010
%% Inputs
% c: is the cell array containing all the signals in matlab
% format.
%
% debug=1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
%
% acq=1: if the script is used during the acquisition phase
%
% np: (name of the person) is the name of the folder in which
% are contained the training data.
%
% i: is the index representing the current single signal to
% process.
%
% plotting=1: to save the figures of the segmented signals
% inside the 'img'folder contained inside the np folder.
% 'img' is automatically created.
%
% ch2=1: if the second channel is used.
%
% ch3=1: if the third channel is used.
%% Outputs
% f: is the cell array containing all the feature vector
% related to the signal contained in c at the position i.
%%
function f=splitFilter(c,debug,acq,plotting,i,np,ch2,ch3)

c1=c{i,1};
c2=c{i,2};
c3=c{i,3};
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
    
    freqCamp=270; %sampling frequencyA.2. Arti?cial Neural Network Training ix
    cutOffFreq=2; %cutoff frequency of the low-pass filter
    nyquistFreq=cutOffFreq/(freqCamp/2);
    [b,a]=butter(2,nyquistFreq);
    %filt is the envelope of the rectified signal
    filt1=filter(b,a,y1);
    filt1=filt1(50:length(filt1));
    
    
    filt2=filter(b,a,y2);
    filt2=filt2(50:length(filt2));
    
    
    filt3=filter(b,a,y3);
    filt3=filt3(50:length(filt3));
    
    
    
    % find the edges of each burst
    [firstDiv,secondDiv]...
        =findBurstEMG(filt1,filt2,filt3,debug,ch2,ch3);
    
    
    %Filtering above 10 Hz
    cutoffF1=10;
    nyquistF=cutoffF1/(freqCamp/2);
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
                    extractFeatures(filtSign2(firstDiv(j):secondDiv(j)));x Appendix A. The Implementation of the Project
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
    for i=2:length(filt1)
        sum1=sum1+filt1(i);
        thr1(i)=sum1/i;
        sum2=sum2+filt2(i);
        thr2(i)=sum2/i;
        sum3=sum3+filt3(i);
        thr3(i)=sum3/i;
    end
    
    
    
    if debug
        % Plots the segmentation of the envelope of the first
        % channel.
        figure;
        plot(1:length(filt1),filt1)
        hold on;
        plot(1:length(thr1),thr1,'y');
        axis([1 length(filt1) 0 150]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
            
        end
        % Plots the segmentation of the envelope of the secondA.2. Arti?cial Neural Network Training xi
        % channel.
        figure;
        plot(1:length(filt2),filt2)
        hold on;
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
        hold on;
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
        if ch3xii Appendix A. The Implementation of the Project
            figure;
            plot(1:length(filtSign3),filtSign3);
            axis([0 length(filtSign3) -400 400]);
            if(~isempty(firstDiv))
                vline(firstDiv,'g','');
                vline(secondDiv,'r','');
            end
        end
        numberOFMovements=length(firstDiv)
        if(~acq)
            ginput(1);
            close all;
        end
        
        
    end
    
    % saving the figures of the fitered and segmented signal
    % into the 'img' folder
    if plotting
        file2save=['/Users/giuseppelisi/University/Thesis/'...
            'Matlab/FilesNewEmg/serial/' np '/ch1/img/image'...
            sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
        fig = figure('visible','off');
        plot(1:length(filtSign),filtSign,'b');
        axis([0 length(filtSign) -400 400]);
        if(~isempty(firstDiv))
            vline(firstDiv,'g','');
            vline(secondDiv,'r','');
        end
        saveas(fig,file2save,'eps');
        
        if ch2
            file2save=['/Users/giuseppelisi/University/Thesis/'...
                'Matlab/FilesNewEmg/serial/' np '/ch2/img/image'...
                sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
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
            file2save=['/Users/giuseppelisi/University/Thesis/'...A.2. Arti?cial Neural Network Training xiii
                'Matlab/FilesNewEmg/serial/' np '/ch3/img/image'...
                sprintf('%d',nsamp) ' ' sprintf('%d',i) '.eps'];
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
