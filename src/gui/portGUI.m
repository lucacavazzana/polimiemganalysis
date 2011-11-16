function port = portGUI
%PORTGUI	Returns the selected serial port
%	PORTGUI launches selection graphical interface for serial port
%	selection. Returns string of the selected port.

%	By Luca Cavazzana for Politecnico di Milano
%	luca.cavazzana@gmail.com
%	13 November 2011


if(ispc())
    ports = {'COM1','COM2','COM3','COM4','COM5','COM6'};
else
    ports = {'TTY1','TTY2','TTY3'};
end

sizeGUI = [200,55];

f = figure('Visible','off','Position',[100, 100, sizeGUI]);

hText = uicontrol('Style', 'text', ...
    'String', 'Port' ,'Position', [10, 45, 40, 18]);

hPorts = uicontrol('Style', 'popupmenu',...
    'String', ports, 'Position', [60, 45, 130, 20]);

hTest = uicontrol('Style', 'pushbutton', ...
    'String', 'Test' ,'Position', [40,10,70,25], ...
    'Callback', {@testCallback});

hSelect = uicontrol('Style', 'pushbutton', ...
    'String', 'Select', 'Position', [120,10,70,25], ...
    'Callback', {@selectCallback});

%align([hTest, hSelect, hPorts],'Center','None');

movegui(f,'center');
set(f,'Name','Select port','Menubar','None');
set(f,'Visible','on');

% my default values...
if(ispc())
    set(hPorts, 'Value', 6);
else
    set(hPorts, 'Value', 6);
end

drawnow;
uiwait;

close(f);


    function testCallback(source, eventdata)
        
        p = get(hPorts, 'Value');
        
        try
            disp(['Opening port ' ports{p}]);
            board = serial(ports{p}, 'BaudRate',57600);
            fopen(board);
            disp(fscanf(board));
            
            fclose(board);
            delete(board);
            disp(['Port ' ports{p} ' closed']);
        catch e
            disp(['Error: unable to open ' ports{p}])
        end
        
    end

    function selectCallback(source,eventdata)
        port = ports{get(hPorts, 'Value')};
        uiresume;
    end

end