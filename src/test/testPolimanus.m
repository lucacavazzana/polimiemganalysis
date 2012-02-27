function testPolimanus()
%	test Polimanus

%	TAG: test

pm = polimanus;
pm.open;

while(1)
    
    fprintf(['\n'...
        '1 - open \n' ...
        '2 - close \n' ...
        '3 - pinch \n' ...
        '4+ - end \n' ...
        ]);
    
    s = input('chose: ');
    
    if(~isempty(s))
        switch(s)
            
            case 1
                pm.moveOpen(255);
                
            case 2
                pm.moveClose(255);
                
            case 3
                pm.movePinch(255);
            otherwise
                disp('bye bye');
                break;
        end
    end
    
end

pm.close;

end