function c = convertAll(np)
%CONVERTALL Gets datas from folder
%   C = CONVERTALL(FOLDER) returns a cell-array containing the signals
%   parsed from the files in FOLDER and their ID
%
%   See also CONVERTFILE2MAT

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

% .../np/chX/#mov-#sequence[-movName].txt
file=[np '/ch1/*.txt'];

files = dir(file);

len = length(files);
c = cell(len, 2);   % [emg, movID]

% for each file in the acquisitions folder
for ii = 1:len
    
    fileName = files(ii).name;
    movement = sscanf(fileName,'%d%*s');    % getting mov number
    
    data = [];
    
    try
        for cc = 3:-1:1
            data(:,cc) = convertFile2MAT(sprintf('%s/ch%d/%s', np, cc, fileName));
        end
    catch err
        err = addCause(err,  MException('ResultChk:OutOfRange', ...
            'Unable to add %s/ch%d/%s', np, cc, fileName));
        throw(err);
    end
    
    c{ii,1} = data;
    c{ii,2} = movement;
end

end