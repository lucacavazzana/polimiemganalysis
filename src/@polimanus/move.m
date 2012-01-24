function move(PM, p1, p2, s1, s2)


% formatting input
mv = 255*ones(1,16);
if(nargin==5)
    mv([1 2 9 10]) = [p1 p2 s1 s2];
elseif(nargin==2)
    if(length(p1)==4)
        mv([1 2 9 10]) = p1;
    elseif(length(p1)==16)
        mv = p1;
    else
        error('wrong parameters');
    end
else
    error('wrong parameters');
end


while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
    pause(.001);
end
fwrite(PM.ser, 253, 'uchar', 'async');
while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
    pause(.001);
end
readasync(PM.ser);
ack = fread(PM.ser, 1, 'uchar');

if(ack ~= 253)
    warning('prepare move got wrong ACK: %d', ack);
end

while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
    pause(.001);
end
fwrite(PM.ser,mv, 'uchar', 'async');
PM.lastSent = mv;

while(strcmp(PM.ser.TransferStatus, 'idle') == 0)
    pause(.001);
end
readasync(PM.ser);
ack = fread(PM.ser, 1, 'uchar');

if(ack ~= rem(sum(mv),256))
    warning('move got wrong ACK: %d (expected %d)', ...
        ack, rem(sum(mv),256));
end

end