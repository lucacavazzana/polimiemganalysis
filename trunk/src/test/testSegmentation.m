emgs = convertAll('asd');

sig = emg(240);

%%

for asd = emgs'
    
    close;
    sig.setSignal(asd{1}-512);
    
    sig.plotBursts;
    
    pause;
end