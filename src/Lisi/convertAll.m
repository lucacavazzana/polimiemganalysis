%% Convert All

% parsa dati: file -> cell. Inutile se passi a pipe.

% This function converts all the txt files into the matlab
% format.
% Future users have to replace
% /Users/giuseppelisi/University/...
%   Thesis/Matlab/FilesNewEmg/serial/
% with their own favourite folder
% Remember that this code is run on a uinix based machine,
% therefore it is
% important to modify some OS oriented commands.
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010

%% Inputs
% debug=1: to pause the segmentation phase and plot the figures
% of each segemented signal. Debug mode
%
% np: is the name of the folder in which are contained the
% training data.
%
% plotting=1: to save the figures of the segmented signals
% inside the 'img' folder contained inside the np folder. 'img'
% is automatically created.
%
%% Outputs
% c: is the cell array containing the converted data.
%%
function [c movNumber]=convertAll(debug,np,plotting)

file=['/Users/giuseppelisi/University/Thesis/'...
    'Matlab/FilesNewEmg/serial/' np '/ch1/*.txt'];
d = dir(file);

fileIndex = find(~[d.isdir]);
len=length(fileIndex);
c = cell(len, 4);
movNumber=1;
movId=[];
movKey=[];



for i = 1:length(fileIndex)
    
    fileName = d(fileIndex(i)).name;
    movement=sscanf(fileName,'%d%*s');
    f=['/Users/giuseppelisi/University/Thesis/Matlab/'...
        'FilesNewEmg/serial/' np '/ch1/' fileName];
    data=convertFile2MAT(f);
    c{i,1}=data;
    f=['/Users/giuseppelisi/University/Thesis/Matlab/'...
        'FilesNewEmg/serial/' np '/ch2/' fileName];
    data=convertFile2MAT(f);
    c{i,2}=data;
    f=['/Users/giuseppelisi/University/Thesis/Matlab/'...
        'FilesNewEmg/serial/' np '/ch3/' fileName];
    data=convertFile2MAT(f);
    c{i,3}=data;
    
    pos=find(movId==movement);
    if(isempty(pos))
        % here the movement IDs are mapped into a key ID in order to
        % make it possible to use data ordered whith different IDs
        % inside the folder
        movId=[movId movement];
        movKey=[movKey movNumber];
        c{i,4}=movNumber;
        movNumber=movNumber+1;
    else
        c{i,4}=movKey(pos);
    end
end
movId
movKey
movNumber=movNumber-1;

end