function plotEmg(DB)
%  plots a random stored burst

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

if(DB.move == 0)
    disp('no gesture selected');
    return;
end


pos = find(DB.targets == DB.move);
sel =  pos(randi(length(pos)));

f = figure;

for ii = 3:-1:1
    subplot(3,1,ii);
    plot(DB.emgs{sel}(:,ii));
    ylabel(sprintf('Ch%d',ii));
end
title(sprintf('gesture %d', DB.move));

DB.move = 0;

end