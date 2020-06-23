%  Written By Joberto Lee 2020


% Takes in xlsx file of data
% For a function of n variables: 
% Columns 3:n+2 represent values of x1 to xn
% Column 1 represents the generation
% Column 2 represents the value of f(X)

% zAlign is either 'gen' to plot generation on the z axis or 'fx' which
% plots the value f(X) on the z axis
% zAlign defaults to 'gen' if other value is given

function radviz3D(file, zAlign)

    data = readmatrix(file,'Sheet', 1);

    zIndex = 0;
    
    if(strcmp(zAlign,'gen'))
        zIndex = 1;
    else
        zIndex = 2;
    end
    zMin = min(data(:,zIndex));
    
    
    radVizData = data(:,3:size(data,2));
    length = size(radVizData, 1);
    n = size(radVizData, 2);

    phi = 2*pi/n;

    anchors = zeros(n,2);
    theta = pi/2;

    for i = 1:n
        anchors(i,1) = cos(theta);
        anchors(i,2) = sin(theta);
        theta = theta + phi;
    end

    points = zeros(length,3);

    for i = 1:length
        sumXi = 0;
        sumXiaix = 0;
        sumXiaiy = 0;

        for j = 1:n
            sumXi = sumXi + radVizData(i,j);
            sumXiaix = sumXiaix + radVizData(i,j)*anchors(j,1);
            sumXiaiy = sumXiaiy + radVizData(i,j)*anchors(j,2);
        end

        points(i, 1) = sumXiaix/sumXi;
        points(i, 2) = sumXiaiy/sumXi;
        points(i, 3) = data(i,zIndex);

    end
    
    circle = zeros(1000,3);
    theta = 0;
    for i = 1:1000
        circle(i,1) = cos(theta);
        circle(i,2) = sin(theta);
        circle(i,3) = zMin;
        
        theta = theta + 2*pi/1000;
    end

    dotsize = 5;
    
    hold on
    scatter3(points(:,1),points(:,2),points(:,3),dotsize,points(:,3),'filled');
    scatter3(circle(:,1),circle(:,2),circle(:,3),1,'.');
    axis([-1.5 1.5 -1.5 1.5 zMin inf]);
    colormap(jet);
    for i = 1:n
        s = "x" + i;
        text(anchors(i,1),anchors(i,2),zMin,s);
    end 
    axis off
    hold off
end
