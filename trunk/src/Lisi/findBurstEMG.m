%% FindBurstEMG
% Function to find the edges of each burst
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010
%% Inputs
% signal1: is the liear envelope of the signal coming from
% Channel 1.
%
% signal2: is the liear envelope of the signal coming from
% Channel 2.
%
% signal3: is the liear envelope of the signal coming from
% Channel 3.
%
% debug=1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
%
% ch2=1: if the second channel is used.
%
% ch3=1: if the third channel is used.
%% Outputs
% secondDivision: vector containing all the ending edges of the
% bursts
% firstDivision: vector conaining all the starting edges of the
% bursts
%%
function [firstDivision,secondDivision]=...
    findBurstEMG(signal1,signal2,signal3,debug,ch2,ch3)

ls=length(signal1); %length of the signal
firstDivision=[];
secondDivision=[];

%54 samples correspond to 0.2 seconds of signal(sampling rate
% 270Samp/Sec) normal burst duration corresponding to 1second
sampleDur=54*5;

%normal movement
delay=40;

%short movement
%delay=20;

%the lower level under which it is impossible to start a burst
cost=10;

%factor for which the initial part of the moving average is
%computed in order to avoid fake initial bursts
mult=30;


%once the burst has been detected its edges have to be shifted
%back of this value
back=100;

% contain the value of the next ending edge. Equal to 1 if the
% start still have to be found
next1=1;
next2=1;
next3=1;

%sum for the threshold computation.
sum1=signal1(1)*mult;
sum2=signal2(1)*mult;
sum3=signal3(1)*mult;

%threshold for the three channels
thr1(1)=sum1;
thr2(1)=sum2;
thr3(1)=sum3;

% records the highest value found so far in all the three
% channels
max=0;

%1 if first channel, 2 if second 3 if third
choice=0;

%restart=1 if the system is ready to detect a new burst
restart=0;

% empiric values for the decision to take about the burst
% start.
perc=22/100;
clos=1/20;

% burst edges detection
for i=2:ls
    
    sum1=sum1+signal1(i);
    thr1(i)=sum1/i;
    sum2=sum2+signal2(i);
    thr2(i)=sum2/i;
    sum3=sum3+signal3(i);
    thr3(i)=sum3/i;
    
    if(signal1(i)>=thr1(i)+perc*thr1(i) &&...
            next1==1 && i>restart && signal1(i)>cost)
        % prev contains the starting point of the edge.
        prev1=i;
        if(prev1-back>1)
            prev1=prev1-back;
            if(prev1+sampleDur<ls)
                next1=prev1+sampleDur;
            else
                next1=1;
            end
        else
            prev1=1;
            next1=1+sampleDur;
        end
    end
    
    if(i==next1)
        %if the signal is still high -> delay the closing
        %of the burst
        if(signal1(i)>thr1(i)-clos*thr1(i))
            if(next1+delay<ls)
                next1=next1+delay;
            else
                next1=ls;
            end
        else
            if(choice==1)
                
                firstDivision=[firstDivision prev1];
                secondDivision=[secondDivision next1];
                max=0;
                choice1=0;
                restart=next1+back;
                next1=1;
                next2=1;
                next3=1;
            end
        end
    end
    
    if(ch2)
        if(signal2(i)>=thr2(i)+perc*thr2(i) && next2==1 &&...
                i>restart && signal2(i)>cost)
            
            prev2=i;
            if(prev2-back>1)
                prev2=prev2-back;
                
                if(prev2+sampleDur<ls)
                    next2=prev2+sampleDur;
                else
                    next2=1;
                end
            else
                prev2=1;
                next2=1+sampleDur;
            end
        end
        if(i==next2)
            %if the signal is still high delay -> the closing
            %of the burst
            if(signal2(i)>thr2(i)-clos*thr2(i))
                if(next2+delay<ls)
                    next2=next2+delay;
                else
                    next2=ls;
                end
            else
                
                if(choice==2)
                    firstDivision=[firstDivision prev2];
                    secondDivision=[secondDivision next2];
                    max=0;
                    choice2=0;
                    restart=next2+back;
                    next1=1;
                    next2=1;
                    next3=1;
                end
            end
        end
    end
    
    if(ch3)
        if(signal3(i)>=thr3(i)+perc*thr3(i) && next3==1 &&...
                i>restart && signal3(i)>cost)
            
            prev3=i;
            
            if(prev3-back>1)
                prev3=prev3-back;
                if(prev3+sampleDur<ls)
                    next3=prev3+sampleDur;
                else
                    next3=1;
                end
            else
                prev3=1;
                next3=1+sampleDur;
            end
        end
        
        if(i==next3)
            %if the signal is still high -> delay the
            %closing of the burst
            if(signal3(i)>thr3(i)-clos*thr3(i))
                if(next3+delay<ls)
                    next3=next3+delay;
                else
                    next3=ls;
                end
            else
                
                if(choice==3)
                    firstDivision=[firstDivision prev3];
                    secondDivision=[secondDivision next3];
                    max=0;
                    choice3=0;
                    restart=next3+back;
                    next1=1;
                    next2=1;
                    next3=1;
                end
            end
        end
    end
    
    if signal1(i)>max && signal1(i)>=thr1(i)+perc*thr1(i)
        max=signal1(i);
        choice=1;
    end
    if signal2(i)>max && ch2 && signal2(i)>=thr2(i)+...
            perc*thr2(i)
        max=signal2(i);
        choice=2;
    end
    if signal3(i)>max && ch3 && signal3(i)>=thr3(i)+...
            perc*thr3(i)
        max=signal3(i);
        choice=3;
    end
end


% if there a burst start has been detected, but not the end,
% eliminate the
% burst
if(~isempty(firstDivision) && ...
        length(firstDivision)>length(secondDivision))
    firstDivision=firstDivision(1:length(secondDivision));
end
