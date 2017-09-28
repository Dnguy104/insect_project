function [ z1 ] = naive_bayes( x1 ,x2 ,x3, x4, x5, x6, x7, x8, x9, x10 )
    x1 = [ x1 ones(5000,1)*1  ];
    x2 = [ x2 ones(5000,1)*2  ];
    x3 = [ x3 ones(5000,1)*3  ];
    x4 = [ x4 ones(5000,1)*4  ];
    x5 = [ x5 ones(5000,1)*5  ];
    x6 = [ x6 ones(5000,1)*6  ];
    x7 = [ x7 ones(5000,1)*7  ];
    x8 = [ x8 ones(5000,1)*8  ];
    x9 = [ x9 ones(5000,1)*9  ];
    x10 =[ x10 ones(5000,1)*10];
    
    arr = [ x1 ;x2 ;x3; x4; x5; x6; x7 ;x8; x9; x10 ];
    order = randperm(size(arr,1))';
    arr = arr(order,:);
    train = arr(1:40000,:);
    test = arr(40001:end,:);
    train = sortrows(train,size(train,2));
    
    testx = test(:,1:end-1);
    testy = test(:,end);
    
    sorted = cell(10,1);
    for x = 1:10
        sorted{x} = train(train(:,end) == x,:);
        
    end
    %disp(num2str(sorted{5,1},'%.2f'))

    avg = cellfun(@mean, sorted,'UniformOutput', false);

    avg = cell2mat(avg);
    dev = cellfun(@std, sorted,'UniformOutput', false);
    dev = cell2mat(dev);
    avg(:,size(avg,2)) = [];
    dev(:,size(dev,2)) = [];
    
    numy = cellfun(@size,sorted,'UniformOutput', false);
    numy = cell2mat(numy);
    numy(:,size(numy,2)) = [];
    numyy = repmat(numy', 10000,1);

    aavg1 = zeros(10000,1);
    aavg2 = zeros(10000,1);
    aavg3 = zeros(10000,1);
    ddev1 = zeros(10000,1);
    ddev2 = zeros(10000,1);
    ddev3 = zeros(10000,1);
    numyyy = dev(:,size(dev,2));
    
    for i = 1:10000
        aavg1(i) = avg(testy(i),1);
        aavg2(i) = avg(testy(i),2);
        aavg3(i) = avg(testy(i),3);
        ddev1(i) = dev(testy(i),1);
        ddev2(i) = dev(testy(i),2);
        ddev2(i) = dev(testy(i),3);
        numyyy(testy(i)) = numyyy(testy(i)) + 1;
    end
    
    size(numyy)
    Pxy1 = - log(ddev1) - (power(testx(:,1) - aavg1,2)/2)./power(ddev1,2);
    Pxy2 = - log(ddev2) - (power(testx(:,2) - aavg2,2)/2)./power(ddev2,2);
    Pxy3 = - log(ddev3) - (power(testx(:,3) - aavg3,2)/2)./power(ddev3,2);
    size(Pxy1)
    size(Pxy2)
    size(numyyy)
    Pxy = Pxy1 .* Pxy2 .* Pxy3 ;
    [i, j] = max(Pxy, [], 2);
    
    
    

    confusion = zeros(10,10);
    for x = 1:10000
       confusion(testy(x),j(x)) =  confusion(testy(x),j(x)) + 1;
    end
    z1 = confusion
end








