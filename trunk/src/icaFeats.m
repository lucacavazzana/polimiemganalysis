function [feats] = icaFeats(x,src)
%ICAFEATS
%     X :   signal to analyze
%   SRC :   src signals to inject during analysis
%
%   OUT :   feats
%
%  Inspired by:
%  L. A. Rivera and G. N. DeSouza, "Recognizing hand movements from a
%  single sEMG sensor using guided under-determined source signal
%  separation", In Rehabilitation Robotics (ICORR), 2011 IEEE International
%  Conference on, pages 1 –6, 29 2011-july 1 2011
%  http://dx.doi.org/10.1109/ICORR.2011.5975392

%  By Luca Cavazzana for Politecnico di Milano
%  luca.cavazzana@gmail.com

CH = minmax(size(x));
LEN = CH(2);
CH = CH(1);

me = mean(x);

gestIt = length(src):-1:1;
for gg = gestIt
    
    d{gg} = (abs(me-src{gg}.mean)./src{gg}.std)'; %#ok<AGROW>
    
    ll = min(length(src{gg}.sig),LEN);
    
    xp = .5*(x(1:ll,:)+src{gg}.sig(1:ll,:));
    
    chIt = CH:-1:1;
    for cc = chIt
        [~, a] = ica([x(1:ll,cc),xp(:,cc)],[],1);
        [~, s] = min(abs(abs(a(2,:)./a(1,:))-.5));   %since fastICA mixes s, we're looking for the column with ratio around [1;.5]
        cp{gg}(cc,1) = abs(a(1,1+(s~=2))/a(1,1+(s==2))); %#ok<AGROW>
    end
end

feats(2*CH*gestIt(1),1)=0;
for gg = gestIt
	feats(2*CH*(gg-1)+1:2*CH*gg)=[cp{gg}; d{gg}];
end

end