function sig = convertFile2MAT(file)
%CONVERTFILE2MAT Extrat emg data from file
%   SIG = CONVERTFILE2MAT(F) returns the data vector A extracted frome txt
%   file F.
%
%   See also CONVERTALL

%  By Giuseppe Lisi for Politecnico di Milano
%  beppelisi@gmail.com
%  8 June 2010

fid = fopen(file);
sig = fscanf(fid, '%d', [1 Inf])';
fclose(fid);

end