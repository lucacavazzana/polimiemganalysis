function [c movNumber] = convertAll(np,plotting)
%CONVERTALL     Gets datas from folder
%	[C MOVNUMBER] = CONVERTALL(FOLDER) returns a cell-array containing the
%	data sets parsed from the files in FOLDER and the number of different
%	gestures MOVNUMBER.
%
%   See also CONVERTFILE2MAT

%	By Luca Cavazzana, Giuseppe Lisi for Politecnico di Milano
%	luca.cavazzana@gmail.com, beppelisi@gmail.com
%	14 November 2011

% .../np/chx/#mov-#sequence[-movName].txt
if(ispc())
    file=[np '\ch1\*.txt'];
else
    file=[np '/ch1/*.txt'];
end
files = dir(file);
%files = files(~[files.isdir]);  % removing directories (useless, since already put *.txt)
len = length(files);
c = cell(len, 4);
movNumber = 0;  % #gestures identified so far
movId = [];
%movName = cell(1);

% for each file in the acquisitions folder
for i = 1:len

    fileName = files(i).name;
    movement = sscanf(fileName,'%d%*s');    % getting mov number
    %movName{i} = sscanf    % TODO: parse mov name too, when you have time
                            % to waste
    if(ispc())
        f = [np '\ch1\' fileName];
    else
        f = [np '/ch1/' fileName];
    end
    data = convertFile2MAT(f);
    c{i,1} = data;
    
    if(ispc())
        f = [np '\ch2\' fileName];
    else
        f = [np '/ch2/' fileName];
    end
    data = convertFile2MAT(f);
    c{i,2} = data;
    
    if(ispc())
        f = [np '\ch3\' fileName];
    else
        f = [np '/ch3/' fileName];
    end
    data = convertFile2MAT(f);
    c{i,3} = data;
    
    % now saving movement ID
    pos = find(movId==movement);  % if movement is not yet met
    if(isempty(pos))
        % here the movement IDs are mapped into a key ID in order to
        % make possible to use data ordered whith different IDs
        % inside the folder
        movNumber = movNumber+1;
        movId = [movId movement];   %#ok
        c{i,4} = movNumber;
    else
        c{i,4} = pos;
    end
end
    % TODO: aggiungi load del mat file
end