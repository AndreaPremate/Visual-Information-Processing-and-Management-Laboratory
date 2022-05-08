function H=calcoloIstogramma(im,N)

H=[];
for ch=1:3
    tmp=hist(im(:,ch),linspace(0,1,N));
    tmp=tmp./sum(tmp);
    H=[H tmp];
end