%% Recognize
% this script recognizes new movements, acquired at the moment.
% It uses a trained ANN
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
% net: is the trained ANN used for the recognition
%
% mov: is the number of movement types on which the ANN has
% been trained.

%% Outputs
%%
function recognize(net,ch2,ch3,mov)

close all;
comm=['./serialComm recognize 1 1 1']
[status,result] = unix(comm,'-echo');
c = cell(1, 4);

file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
    'FilesNewEmg/serial/recognize/ch1/1-1-1.txt'];

fid = fopen(file);
c{1,1} = fscanf(fid, '%d', [1 inf])';

fclose(fid);


file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
    'FilesNewEmg/serial/recognize/ch2/1-1-1.txt'];

fid = fopen(file);
c{1,2} = fscanf(fid, '%d', [1 inf])';

fclose(fid);


file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
    'FilesNewEmg/serial/recognize/ch3/1-1-1.txt'];

fid = fopen(file);
c{1,3} = fscanf(fid, '%d', [1 inf])';

fclose(fid);

c{1,4}=0;

% extract the feature vectors from the burst contained in the
% single signal
f=splitFilter(c,1,0,0,1,'recognize',ch2,ch3)'

% uses the ANN to reognize the movement performed.
if(~isempty(f))
    out = sim(net,f);
    
    
    % performance evaluation, depending on the number of movements
    % on which the ANN is trained
    lout=length(out(1,:));
    if mov==7
        for i=1:lout
            y= ismember(out(:,i),max(out(:,i)))'
            if(eq(y,[1 0 0 0 0 0 0]))
                [status,result] = unix('say close hand','-echo');
            elseif (eq(y,[0 1 0 0 0 0 0]))
                [status,result] = unix('say open hand','-echo');
            elseif (eq(y,[0 0 1 0 0 0 0]))
                [status,result] = unix('say wrist extension','-echo');
            elseif (eq(y,[0 0 0 1 0 0 0]))
                [status,result] = unix('say wrist flexion','-echo');
            elseif (eq(y,[0 0 0 0 1 0 0]))
                [status,result] = unix('say thumb abduction','-echo');
            elseif (eq(y,[0 0 0 0 0 1 0]))
                [status,result] = unix('say thumb opposition','-echo');
            elseif (eq(y,[0 0 0 0 0 0 1]))
                [status,result] = unix('say index extension','-echo');
            end
        end
    end
    
    
    if mov==6
        for i=1:lout
            y= ismember(out(:,i),max(out(:,i)))'
            if(eq(y,[1 0 0 0 0 0]))
                [status,result] = unix('say close hand','-echo');
            elseif (eq(y,[0 1 0 0 0 0]))
                [status,result] = unix('say open hand','-echo');
            elseif (eq(y,[0 0 1 0 0 0]))
                [status,result] = unix('say wrist extension','-echo');
            elseif (eq(y,[0 0 0 1 0 0]))
                [status,result] = unix('say wrist flexion','-echo');
            elseif (eq(y,[0 0 0 0 1 0]))
                [status,result] = unix('say thumb abduction','-echo');
            elseif (eq(y,[0 0 0 0 0 1]))
                [status,result] = unix('say thumb opposition','-echo');
            end
        end
    end
    
    if mov==5
        for i=1:lout
            y= ismember(out(:,i),max(out(:,i)))'
            if(eq(y,[1 0 0 0 0]))
                [status,result] = unix('say close hand','-echo');
            elseif (eq(y,[0 1 0 0 0]))
                [status,result] = unix('say open hand','-echo');
            elseif (eq(y,[0 0 1 0 0]))
                [status,result] = unix('say wrist extension','-echo');
            elseif (eq(y,[0 0 0 1 0]))
                [status,result] = unix('say wrist flexion','-echo');
            elseif (eq(y,[0 0 0 0 1]))
                [status,result] = unix('say thumb abduction','-echo');
            end
        end
    end
    
    if mov==4
        for i=1:lout
            y= ismember(out(:,i),max(out(:,i)))'
            if(eq(y,[1 0 0 0]))
                [status,result] = unix('say close hand','-echo');
            elseif (eq(y,[0 1 0 0]))
                [status,result] = unix('say open hand','-echo');
            elseif (eq(y,[0 0 1 0]))
                [status,result] = unix('say wrist extension','-echo');
            elseif (eq(y,[0 0 0 1]))
                [status,result] = unix('say wrist flexion','-echo');
            end
        end
    end
    
    if mov==3
        for i=1:lout
            y= ismember(out(:,i),max(out(:,i)))'
            if(eq(y,[1 0 0]))
                [status,result] = unix('say close hand','-echo');
            elseif (eq(y,[0 1 0]))
                [status,result] = unix('say open hand','-echo');
            elseif (eq(y,[0 0 1]))
                [status,result] = unix('say wrist extension','-echo');
                
            end
        end
    end
    
    if mov==2
        for i=1:lout
            y= ismember(out(:,i),max(out(:,i)))'
            if(eq(y,[1 0]))
                [status,result] = unix('say close hand','-echo');
            elseif (eq(y,[0 1]))
                [status,result] = unix('say open hand','-echo');
            end
        end
    end
    
end
end