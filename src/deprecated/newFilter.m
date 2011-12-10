function [y] = newFilter(x, xOld, yOld)
% filter originale più veloce nell'analizzare 4K dati che non questo con
% 20... Riscrivere in C o ciccia.

[num, den] = butter(2, 0.0148);

if nargin==1
    y = filter(num,den,x);

else
    den = -den([2,3]);
    y = zeros(size(x));
%     keyboard
    y(1) = num*[x(1); xOld([2,1])] + den*yOld([2,1]);
    y(2) = num*[x([2,1]); xOld(2)] + den*[y(1); yOld(2)];
    for ii = 3:length(x)
        y(ii) = num*x([ii,ii-1,ii-2]) + den*y([ii-1,ii-2]);
    end
end

end


% A question about the |filter| function: I'm processing blocks of a continuous signal from an external device as they arrive. But, obviously
% 
%   filter(b,a, [block1, block2]) ~= [filter(b,a,block1), filter(b,a,block2)]
% 
% Since I don't want to re-filter the complete signal every time I get a new block I wrote a custom-made version of |filter| which allows me to concatenate the new filtered block.