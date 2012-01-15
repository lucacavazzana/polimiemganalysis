function port = burstGUI(gName,rep)
%BURSTGUI

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com

global ACQ;
global THISREP;
ACQ = 0;
THISREP = 1;

sizeGUI = [170,85];

f = figure('Visible', 'off', ...
    'Name', sprintf('%s, %d', gName, rep), ...
    'NumberTitle', 'off', ...
    'Menubar', 'None', ...
    'Resize', 'off', ...
    'Position',[100, 100, sizeGUI]);
    
hGest = uicontrol('Style', 'text',...
    'String', sprintf('%s, %d', gName, rep), 'Position', [10, 65, 150, 20]);

hAct = uicontrol('Style', 'text',...
    'String', 'STOPPED', ...
    'BackgroundColor', 'red', ...
    'Position', [10, 45, 150, 20]);

switchButt = uicontrol('Style', 'pushbutton', ...
    'String', 'Acq', ...
    'Position', [10,10,70,25], ...
    'Callback', {@switchCallback});

hDone = uicontrol('Style', 'pushbutton', ...
    'String', 'Done', 'Position', [90,10,70,25], ...
    'Callback', {@exitCallback});

movegui(f,'center');
set(f, 'Visible','on');

drawnow;

    function switchCallback(source,eventdata)
        if ACQ
            set(switchButt,'String','Stop');
            set(hAct,'String','STOPPED');
            set(hAct,'BackgroundColor','red');
            ACQ = 0;
        else
            set(switchButt,'String','Acq');
            set(hAct,'BackgroundColor','green');
            set(hAct,'String','ACQUIRING');
            ACQ = 1;
        end
    end

    function exitCallback(source,eventdata)
        ACQ = 0;
        THISREP = 0;
        close(f);
    end

end