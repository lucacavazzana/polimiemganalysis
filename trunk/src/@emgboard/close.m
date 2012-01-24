function status = close(EB)


fclose(EB.ser);

status = 1;
end