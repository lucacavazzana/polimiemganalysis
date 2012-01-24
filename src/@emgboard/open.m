function status = open(EB)


EB.ser = serial(EB.port);
set(EB.ser, 'BaudRate', 57600);
set(EB.ser, 'InputBufferSize',  4590);
set(EB.ser, 'RecordName', 'emgboard.txt');
set(EB.ser, 'Tag', 'EmbBoard');

fopen(EB.ser);

status = 1;
end