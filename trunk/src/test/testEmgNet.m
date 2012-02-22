%	test the emgnet class. It must return the same results. It plot
%   execution times too

%   TAG: test

clear all;
load('halfNets10A.mat', 'net'); % saved net here

net = net{1};
asd = emgnet(net);

while (1)
    
    in = rand(21,1);
    
    tic;
    res1 = sim(net,in);
    t1 = toc;
    
    tic;
    res2 = sim(asd,in);
    t2 = toc;
    
    assert(all(res1==res2));
    
    fprintf('old net: %f --- new net: %f\n',t1, t2);
    
end