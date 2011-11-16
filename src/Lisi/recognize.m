function ges = recognize(nn, ch2, ch3, mov)
%RECOGNIZE  Gesture classification using NN
%   GES = RECOGNIZE(NN, CH2, CH3, MOV) acquires gesture EMG and returns the
%   related ID using the nerual network NN. MOV is the number of gestures.

%	By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%	luca.cavazzana@gmail.com, beppelisi@gmail.com
%	15 November 2011

% Inputs
% nn: is the trained ANN used for the recognition
%
% mov: is the number of movement types on which the ANN has
% been trained.

close all;
global SERIALCOMM;
global DEBUG;
global PORT;

[status,result] = system([SERIALCOMM ' -a -p rec -i 1 -s 1']);

if(status)
    error('Problems acquiring from serial');
end

c = cell(1, 4);

if(ispc())
    file = 'rec\ch1\1-1.txt';
else
    file = 'rec/ch1/1-1.txt';
end

% scanning files
fid = fopen(file);
c{1,1} = fscanf(fid, '%d', [1 inf])';
fclose(fid);

file(7) = '2';
fid = fopen(file);
c{1,2} = fscanf(fid, '%d', [1 inf])';
fclose(fid);

file(7) = '3';
fid = fopen(file);
c{1,3} = fscanf(fid, '%d', [1 inf])';
fclose(fid);

c{1,4}=0;

% extract the feature vectors from the burst contained in the
% single signal
f = splitFilter(c,1,0,0,1,'recognize',ch2,ch3)'

% uses the ANN to reognize the movement performed.
if(~isempty(f))
    out = sim(nn,f);
    
    % performance evaluation, depending on the number of movements
    % on which the ANN is trained
    lout = length(out(1,:));
    
    movIDs = 1:mov;
    ges = zeros(1,mov);
    
    for i = 1:lout
        ges(i) = max(out(:,i));
        printf('- Gesture %d', ges(i));
    end
    
end
end
