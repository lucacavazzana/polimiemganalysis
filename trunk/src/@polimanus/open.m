function status = open(PM)


PM.ser = serial(PM.port);
set(PM.ser, 'BaudRate', 115200);
set(PM.ser, 'Terminator', 'LF');
set(PM.ser, 'InputBufferSize', 10000);
set(PM.ser, 'timeout', 0.5);
set(PM.ser, 'RecordName', 'polimanus.txt');
set(PM.ser, 'RecordDetail', 'verbose');
set(PM.ser, 'Tag', 'Polimanus');

fopen(PM.ser);

status = 0;
end