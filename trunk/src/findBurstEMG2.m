function [firstDiv, secondDiv] = ...
    findBurstEMG(s1, s2, s3, debug, ch2, ch3)
% REWRITING FINDBURSTEMG
%FINDBURSTEMG   Finds the edges of each burst
%   [FIRSTDIV, SECONDDIV] = FINDBURSTEMG(S1, S2, S3)
%   returns the vector of the starting edge FIRSTDIVISION and ending edge
%   SECONDDIVISION of the bursts, where S1, S2 and S3 are the linear
%   envelope of the signal coming from ch1, ch2 and ch3.

%	By Giuseppe Lisi for Politecnico di Milano
%	beppelisi@gmail.com
%	8 June 2010
%% Inputs
%
% debug=1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
%
% ch2=1: if the second channel is used.
%
% ch3=1: if the third channel is used.
%%
%   calcolato segnale integrale (inizio alzato un po' per evitare falsi
%   positivi iniziali). 

ls = min([length(s1), length(s2), length(s3)]); % length of the signal
firstDiv = [];
secondDiv = [];

% 54 samples correspond to 0.2 seconds of signal(@ 270samp/sec)
% Normal burst duration corresponds to 1 second
sampleDur = 54*5;

% normal movement
delay = 40;

% short movement
% delay = 20;

cost = 10; % the lower level under which it is impossible to start a burst

% factor to avoid initial part of the moving average triggers fake initial
% bursts
mult = 30;


% once the burst has been detected its edges have to be shifted
% back of this value
back = 100;

% contain the value of the next ending edge. Equal to 1 if the
% start still have to be found
next1 = 1;
next2 = 1;
next3 = 1;

% sums for the threshold computation and thresholds
sum1 = s1(1:ls); sum1(1) = s1(1)*mult;
sum1 = cumsum(sum1);
thr1 = sum1./(1:ls);

sum2 = s2(1:ls); sum2(1) = s2(1)*mult;
sum2 = cumsum(sum2);
thr2 = sum2./(1:ls);

sum3 = s3(1:ls); sum3(1) = s3(1)*mult;
sum3 = cumsum(sum3);
thr3 = sum3./(1:ls);

% records the highest value found so far in all the three
% channels
max = 0;

% 1 if first channel, 2 if second 3 if third
choice = 0;

% restart = 1 if the system is ready to detect a new burst
restart = 0;

% empiric values for the decision to take about the burst
% start.
perc = 1.22;
clos = .05;

% burst edges detection
for i = 2:ls
    
    if(s1(i) >= thr1(i)*perc && ... qua si potrebbe riordinare
            next1 == 1 && i > restart && ...
            s1(i)>cost)
        % prev contains the starting point of the edge.
        prev1 = i;
        if(prev1-back>1)
            prev1=prev1-back;
            if(prev1+sampleDur<ls)
                next1=prev1+sampleDur;
            else
                next1=1;	% FIXME: inutile, se siamo qui dentro è già 1!
            end
        else
            prev1=1;
            next1=1+sampleDur;
        end
    end
    
    if(i==next1)
        %if the signal is still high -> delay the closing
        %of the burst
        if(s1(i)>thr1(i)-clos*thr1(i))
            if(next1+delay<ls)
                next1=next1+delay;
            else
                next1=ls;
            end
        else
            if(choice==1)
                
                firstDiv=[firstDiv prev1];
                secondDiv=[secondDiv next1];
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
        if(s2(i) >= thr2(i)*perc && next2==1 &&...
                i>restart && s2(i)>cost)
            
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
            if(s2(i)>thr2(i)-clos*thr2(i))
                if(next2+delay<ls)
                    next2=next2+delay;
                else
                    next2=ls;
                end
            else
                
                if(choice==2)
                    firstDiv=[firstDiv prev2];
                    secondDiv=[secondDiv next2];
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
        if(s3(i) >= thr3(i)*perc && next3==1 &&...
                i>restart && s3(i)>cost)
            
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
            if(s3(i)>thr3(i)-clos*thr3(i))
                if(next3+delay<ls)
                    next3=next3+delay;
                else
                    next3=ls;
                end
            else
                
                if(choice==3)
                    firstDiv=[firstDiv prev3];
                    secondDiv=[secondDiv next3];
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
    
    if (s1(i)>max && s1(i)>=thr1(i)*perc)
        max=s1(i);
        choice=1;
    end
    if (ch2 && s2(i)>max && s2(i)>=thr2(i)*perc)
        max=s2(i);
        choice=2;
    end
    if (ch2 && s3(i)>max && ch3 && s3(i)>=thr3(i)*perc)
        max=s3(i);
        choice=3;
    end
end


% if there a burst start has been detected, but not the end,
% eliminate the
% burst
if(~isempty(firstDiv) && ...
        length(firstDiv)>length(secondDiv))
    firstDiv=firstDiv(1:length(secondDiv));
end
