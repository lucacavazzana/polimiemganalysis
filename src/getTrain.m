function [train, test] = getTrain(elem, perc)
%GETTRAIN   returns train and test indices
%   [TRAIN, TEST] = GETTRAIN(ELEM,PERC) get the total number of elements
%   ELEM, the train percentage PERC and will return the ramdomly partitioned
%   indices of train and test elements (divided accordingly to PERC, rounded
%   up for the training set).

%   By Luca Cavazzana for Politecnico di Milano
%   luca.cavazzana@gmail.com


if (isscalar(elem))
    nEl = elem;
else
    nEl = length(elem);
end

if (perc>1)
    perc=perc/100;
end

perm = randperm(nEl);
train = sort(perm(1:ceil(nEl*perc)));
test = sort(perm(ceil(nEl*perc)+1:end));

end