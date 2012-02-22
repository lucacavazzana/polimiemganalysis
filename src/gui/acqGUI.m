function [n, rep, gests, name] = acqGUI()
%GESTGUI    Get gesture names
%   [N, NREP, GESTS, NAME] = ACQGUI() displays a graphical interface where
%   the user can select the number of gestures N, the number of repetitions
%   NREP, their name GESTS and the NAME of the patient.

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com

% default values
n = 7;
gests = {'closeHand', ...
    'openHand', ...
    'wristExtension', ...
    'wristFlexion', ...
    'thumbAbduction', ...
    'thumbOpposition', ...
    'indexExtension'};

sizeGUI = [230,210];

f = figure('Visible', 'off', ...
    'Name', 'Gestures', ...
    'NumberTitle', 'off', ...
    'Menubar', 'None', ...
    'Resize', 'off', ...
    'Position', [100, 100, sizeGUI]);

hBox = zeros(1,7);
for i = 1:7
    hBox(i) = uicontrol('Style', 'edit', ...
        'String', gests{i} ,'Position', [10, 220-i*30, 100, 20]);
end

% second column

patLabel = uicontrol('Style', 'text', ...
    'String', 'Patient name' ,'Position', [120, 190, 100, 15]);

patBox = uicontrol('Style', 'edit', ...
    'String', 'newAcq' ,'Position', [120, 170, 100, 20]);

numLab = uicontrol('Style', 'text', ...
    'String', '#gestures' ,'Position', [130, 105, 80, 18]);

numBox = uicontrol('Style', 'popupmenu', ...
    'String', (2:7)' ,'Position', [130, 85, 80, 20], 'Value', 6, ...
    'Callback', {@selCallback});

repLab = uicontrol('Style', 'text', ...
    'String', '#repetitions' ,'Position', [130, 55, 80, 18]);

repBox = uicontrol('Style', 'edit', ...
    'String', '2' ,'Position', [130, 35, 80, 20]);

okButt = uicontrol('Style', 'pushbutton', ...
    'String', 'OK' ,'Position', [120, 10, 100, 25], ...
    'CallBack', {@okCallback});

movegui(f,'center');
set(f,'Visible','on');

drawnow;
uiwait(gcf);

close(f);

    function selCallback(source, eventdata)
        v = get(numBox, 'Value')+1;
        set(hBox(v:7), 'Enable', 'off');
        set(hBox(2:v), 'Enable', 'on');
        drawnow;
    end

    function okCallback(source, eventdata)
        
        name = get(patBox, 'String');
        if(isempty(name))
            disp(' - Warning: insert a patient name');
            return;
        end
        
        n = get(numBox, 'Value')+1;
        gests = get(hBox(1:n), 'String');
        
        for j=1:length(gests)
            gests{j}(gests{j}==' ')='_';
        end
        
        
        rep = str2num(get(repBox, 'String')); %#ok<ST2NM>
        if(rep<1)
            disp(' - Warning: invalid repetition number');
            return;
        end
        
        uiresume(gcf);
    end
end