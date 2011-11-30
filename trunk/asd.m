function asd

patient = 'asd';
load([patient,'\gest.mat']);

% 270/2 is the max freq we can see @270 sample/sec. This way we are cutting
% off 2Hz for signal segmentation
[b,a] = butter(2, 4/270);

fig=figure; hold on;
for ii=1:size(gest,1)
    for jj=1:gest{ii,3}
        clf(fig);
        emg=[];
        
        for cc=1:3
            f = fopen(sprintf('%s\\ch%d\\%d-%d-%s.txt', patient, cc, gest{ii,1}, jj, gest{ii,2}));
            emg(:,cc) = fscanf(f,'%d');
            fclose(f);
        end
        
        % preprocessing
        emg = abs(emg-512); % FIXME: but mean value is around 524
        splt = filter(b, a, emg);
        
        [head,tail] = myFindBurst2(splt);
        
        %emg(1:50)=[];
        
        for cc=1:3
            subplot(3,1,cc);
            hold on;
            plot(splt(:,cc));
            line([head;tail],10*ones(2,length(head)),'LineWidth',3);
        end
    end
    
    disp(gest{ii,2});
    pause;
end

close(fig);

end