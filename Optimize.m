
function [optData] = Optimize

    %Number of variables
    n = 5;

    %Set all bounds to (0.01,0.99)
    LB = (zeros(1,n)+1)*0.01;
    UB = (zeros(1,n)+1)*0.99;

    %Define Linear Constraints
    A = [55 45 40 10 25
         15 15 45 65 50
         30 40 15 25 25
          1  1  1  1  1];
 
    b = [45
         30
         25
          1];

    %Setup output function
    options = optimoptions('ga','OutputFcn',@outfun);

    [optData.xSol, optData.minCost] = ga(@costFunction, n, [], [], A, b, LB, UB, [], options);

    %Define Output Function
    function [state,options,optchanged] = outfun(options,state,flag)
        persistent vals;
        
        optchanged = false;

        switch flag
            case 'init'
                
            case 'iter'
                
                % Default population size is 50 for Xn < 6
                temp = (zeros(50,1)+1)*state.Generation;
                vals = [vals; temp state.Score state.Population];

            case 'done'
                
                optData.popData = vals;
                vals = [];
                
            otherwise
        end
    end
    
    %Define Optimization Function
    function y = costFunction(x)
        y = 6 * x(1) + 8* x(2) + 7 * x(3) + 2 * x(4) + 3 * x(5);
    end
    
end