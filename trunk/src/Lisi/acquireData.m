function acquireData(np, mov, id, prog)
%ACQUIREDATA    Acquires data from the EMG board.
%   ACQUIREDATA calls an external application written in C, which starts
%   the communication with the board and saves the signals into different
%   folders. This script actually load the data stored into the folders
%   created by the C application.
%
%   INPUTS:
%   np:     folder where ouput data will be saved (tipically the name of
%           the patient).
%   mov:    (subfolder) name of the movement.
%   id:     code of the movement.
%   prog:   progressive number

%	By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%	luca.cavazzana@gmail.com, beppelisi@gmail.com
%	9 November 2010

close all;

if(ispc())
    serialComm = 'C:\Users\luca\workspace\serialComm\Debug\';    % FIXME: this is my path...
    serialComm = [serialComm 'serialComm.exe'];
else
    serialComm = './serialComm ';
end

% calls the external application serialComm, which creates a
% new folder and store the acquired data inside (txt files).
[status, result] = system([serialComm ' -d ' port ' -n ' ...
    sprintf('%d',1) ' -o ' np ' -g ' mov sprintf('%d', prog)]);

if(status == -1)
    error(result);
end

c = cell(1, 4);

% the txt files saved by the external application are loaded by the script.
if(ispc())
    file = [np '\' mov sprintf('%d', prog) '\ch1.txt'];
else
    file = [np '/' mov sprintf('%d', prog) '/ch1.txt'];
end

fid = fopen(file);
c{1,1} = fscanf(fid, '%d', [1 inf])';
fclose(fid);

file(end-4) = '2';
fid = fopen(file);
c{1,2} = fscanf(fid, '%d', [1 inf])';
fclose(fid);

file(end-4) = '3';
fid = fopen(file);
c{1,3} = fscanf(fid, '%d', [1 inf])';
fclose(fid);

c{1,4} = mov;

disp(c{1,1});

% useful to see if the signal has been segmented well.
splitFilter(c,1,1,0,1,np,1,1);

end