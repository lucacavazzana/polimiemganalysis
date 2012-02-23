%	open emgBoard and plots raw data

%	TAG: test

close all;

board = emgboard('COM13', ...
    'dumpboard.txt');
board.open;

board.plotEmg;