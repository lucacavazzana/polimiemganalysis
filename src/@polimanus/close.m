function close(PM)


if (strcmp(PM.ser.TransferStatus, 'idle') == 0)
    stopasync(PM.ser);
end

fclose(PM.ser);
end