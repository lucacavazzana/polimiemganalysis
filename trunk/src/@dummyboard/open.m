function open(DB, varargin)
%OPEN load burst samples and open burst GUI

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com

load(DB.port);
DB.emgs = emgs;
DB.targets = targets;

DB.dummyboardGUI();

end