%https://www.programmersought.net/article/376755737.html
function O = renyisEntropy(I)
img = im2gray(I);
[m n]=size(img);
Hist=imhist(img);
q=2;
H=[];
for k=2:256
    PA=sum(Hist(1:k-1));
    PB=sum(Hist(k:255));
    
    Pa=Hist(1:k-1)/PA;
    Pb=Hist(k:256)/PB;
    
    HA=(1/1-q)*log(sum(Pa.^q));
    HB=(1/1-q)*log(sum(Pb.^q));
    
    H=[H HA+HB];    
end

[junk level]=max(H);
imgn=im2bw(mat2gray(img),level/256);
figure;
O = imgn;