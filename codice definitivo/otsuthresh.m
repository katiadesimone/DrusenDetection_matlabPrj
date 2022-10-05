function OthsuT = otsuthresh(f) 
%0TSUTHRESH Otsu 's optimum threshold given a histogram . 
% [T, SM] = OTSUTHRESH (H) computes an optimum threshold , T, in the 
% range [O 1] using Otsu 's method for a given a histogram , H.
% Normalize the histogram to unit area . If h is already normalized , 
% the following operation has no effect . 
h = imhist(f);
h= h/sum(h);
h = h(:); % h must be a column vector for processing below .
% All the possible intensities represented in the histogram (256 for 
% 8 bits) . (i must be a column vector for processing below. ) 
i = (1:numel(h))';
% Values of P1 for all values of k. 
P1 = cumsum(h);
% Values of the mean for all values of k. 
m = cumsum(i.*h);
% The image mean . 
mG = m(end);
% The between - class variance . 
sigSquared = ((mG*P1 - m).^2)./(P1.*(1-P1)+eps);
% Find the maximum of sigSquared . The index where the max occurs is 
% the optimum threshold . There may be several contiguous max values . 
% Average them to obtain the final threshold . 
maxSigsq = max(sigSquared); 
T = mean(find(sigSquared == maxSigsq));
% Normalized to range [O 1). 1 is subtracted because MATLAB indexing 
% starts at 1, but image intensities start at o. 
T = (T - 1)/(numel(h) - 1);
% Separability measure . 
SM = maxSigsq/(sum(((i - mG).^2).*h)+eps);
OthsuT = im2bw(f,T/255);