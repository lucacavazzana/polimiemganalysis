1 %% ConvertFile2Mat
2 % This function converts each single txt file in matlab format
3 %
4 % By Giuseppe Lisi for Politecnico di Milano
5 % beppelisi@gmail.com
6 % 8 June 2010
7 %% Inputs
8 % file: is the file to convert
9 %% Outputs
10 % a: is the converted matlab file
11 %%
12 function a=convertFile2MAT(file)
13
14 fid = fopen(file);
15 a = fscanf(fid, '%d', [1 inf])';
16 fclose(fid);
17
18
19 end