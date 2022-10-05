function matrix = myfunction(mask,x,y)
boundaries = bwboundaries(mask);
boundaries = boundaries{1,1};
numberOfBoundaries = size(boundaries);
numberOfBoundaries = numberOfBoundaries(1);
Matrix = ones(numberOfBoundaries,3);                       
%ho impostato un ciclo for per trovare la distanza massima e le coordinate
%del punto alla massima distanza dal centro del disco ottico)
for k = 1:numberOfBoundaries
    distance = sqrt( (x - boundaries(k,2) )^2 + (y - boundaries(k) )^2 );
    Matrix(k, :) = [distance boundaries(k,2) boundaries(k)];
end
SortedMatrix = sortrows(Matrix,"descend");
matrix = SortedMatrix;