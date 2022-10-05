%% Global Threshold Gonzalez
function GT_image = gThresh(f)
count = 0;
T = mean2(f);
done = false;
while -done
    count = count + 1; 
    g = f > T;
    Tnext = 0.5*(mean(f(g)) + mean (f(-g))); 
    done = abs(T-Tnext) < 0.5;
    T = Tnext;
end 
GT_image = im2bw(f,T/144);