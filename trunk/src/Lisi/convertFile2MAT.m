%% ConvertFile2Mat
% This function converts each single txt file in matlab format
%
% By Giuseppe Lisi for Politecnico di Milano
% beppelisi@gmail.com
% 8 June 2010
%% Inputs
% file: is the file to convert
%% Outputs
% a: is the converted matlab file
%%
function a=convertFile2MAT(file)

fid = fopen(file);
a = fscanf(fid, '%d', [1 inf])';
fclose(fid);

end