%% AcquireData
% This function is used to acquire the data from the EMG board.
% It calls an external application written in C, which starts
% the communication with the board and saves the signals into
% different folders.
% This script actually load the data stored into the folders
% created by the C application.
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010
%% Inputs
%
% np: is the new folder in which we want to save the acquired
% data. Usually it is the name of the person.
%
% mov: is the name of the movement.
%
% id: is the movement id (for example the ID of the Close Hand
% is 1)
%
% prog: is the progressive number of a given movement (at the
% first acquisition of a Close Hand the prog is 1, at the
% second acquisition of the Close Hand is 2 and so on )
%% Outputs
%%
function acquireData(np,mov,id,prog)
close all;
%calls the external application serialComm, which creates a new
%folder and store the acquired data inside (txt files).
comm=['./serialComm ' np ' ' mov ' ' sprintf('%d',id) ' ' prog]
[status,result] = unix(comm,'-echo');
c = cell(1, 4);

%the txt files saved by the external application are loaded by
%the script.
file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
    'FilesNewEmg/serial/' np '/ch1/' sprintf('%d',id)...
    '-' prog '-' mov '.txt'];

fid = fopen(file);
c{1,1} = fscanf(fid, '%d', [1 inf])';

fclose(fid);

file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
    'FilesNewEmg/serial/' np '/ch2/' sprintf('%d',id)...
    '-' prog '-' mov '.txt'];

fid = fopen(file);
c{1,2} = fscanf(fid, '%d', [1 inf])';

fclose(fid);

file=['/Users/giuseppelisi/University/Thesis/Matlab/'...
	'FilesNewEmg/serial/' np '/ch3/' sprintf('%d',id)...
    '-' prog '-' mov '.txt'];

fid = fopen(file);
c{1,3} = fscanf(fid, '%d', [1 inf])';

fclose(fid);
c{1,4}=id;

% useful to see if the signal has been segmented well.
f=splitFilter(c,1,1,0,1,np,1,1);

end