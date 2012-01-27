function open(DB)
%  load burst samples and open burst GUI
%  returns GUI handler

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

load(DB.port);
DB.emgs = emgs;
DB.targets = targets;

DB.dummyboardGUI();

end