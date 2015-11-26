    function close = isClose(centers1, centers2) 
        close = false;
        epsilon = 10;
        if (abs(centers1(1) - centers2(1)) < epsilon && abs(centers1(2) - centers2(2)) < epsilon )
            close = true;
    end