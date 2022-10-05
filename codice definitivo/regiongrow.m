function [g, NR , SI , TI ] = regiongrow(f, S, T)
%REGIONGROW Perform segmentation by region growing .
% [G, NR , SI , Tl ) = REGIONGROW(F, s, T ) . 
% s can be an array ( the same size as F) with a 1 at the coordinates 
% of every seed point and Os elsewhere . S can also be a single seed value.
% T can be an array ( the same size as F) containing a th reshold
% value for each pixel in F. T can also be a scalar , in which case
% it becomes a global th reshold. 
% All values in S and T must be in the range (0, 1)
S=double(S);
T=double(T);
%I = tofloat(f);
% G is the result of region growing , with each region labeled by a
% different intege r, NR is the number of regions , SI is the final
% seed image used by the algorithm , and TI is the image consisting
% of the pixels in F t hat sat isfied the th reshold test , but before
% they were processed for connectivity .
% If s is a scalar, obtain the seed image .
if numel(S) == 1
    SI = f == S;
    S1 = S;
else
% S is an array . Eliminate duplicate, connected seed locations
% to reduce the number of loop executions in the following
% sections of code.
    SI = bwmorph(S, 'shrink', Inf);
    S1 = f(SI); % Array of seed values.
end
TI = false(size(f));
for K = 1:length(S1)
    seedvalue = S1(K);
    S = abs(f - seedvalue) <= T; % Re - use variable S.
    TI = TI | S;
end
% Use function imreconstruct with SI as the marker image to
% obtain the regions corresponding to each seed in S. Function
% bwlabel assigns a different integer to each connected region .
[g, NR] = bwlabel(imreconstruct(SI,TI)); 