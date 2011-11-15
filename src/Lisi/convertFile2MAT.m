function a = convertFile2MAT(file)

%CONVERTFILE2MAT    Extrat EMG data from file
%	A = CONVERTFILE2MAT(F) returns the data vector A extracted frome txt
%	file F.
%
%   See also CONVERTALL

%	By Giuseppe Lisi for Politecnico di Milano
%	beppelisi@gmail.com
%	8 June 2010

fid = fopen(file);
a = fscanf(fid, '%d', [1 inf])';
fclose(fid);

end