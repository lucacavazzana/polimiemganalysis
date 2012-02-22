function testPolimanus()
%	test Polimanus

%	TAG: test

pm = polimanus;
pm.open;

while 1
    
    fprintf(['\n'...
        '1 - open \n' ...
        '2 - close \n' ...
        '3 - pinch \n' ...
        '4 - end \n' ...
        ]);
    
    s = input('chose:');
    
    switch(s)
        
        case 1
            pm.open(255);
            
        case 2
            pm.close(255);
            
        case 3
            pm.pinch(255);
        otherwise
            disp('bye');
            break;
    end
    
end

end