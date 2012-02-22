%	open emgBoard and plots raw data

%	TAG: test

close all;

board = emgboard([], ...
    'dumpboard.txt');
board.open;

board.plotEmg;