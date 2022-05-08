% immagine esempio (template)
boxImage = imread('./immaginiObjectDetection/stapleRemover.jpg');
% immagine scena
sceneImage = imread('./immaginiObjectDetection/clutteredDesk.jpg');

%% ricerca sliding window
boxImage = imcrop(boxImage);

figure(1), imshow(boxImage)
[x,y]=ginput(2);
Sbox=sqrt(sum((x-y).^2));

figure(2), imshow(sceneImage)
[x,y]=ginput(2);
Sim=sqrt(sum((x-y).^2));

%%
template=imresize(boxImage,Sim/Sbox);
template=im2double(template);
sceneImage=im2double(sceneImage);

mappa=[];
passo=10;
tic
for rr=1:passo:size(sceneImage,1)-size(template,1)
    tmp=[];
    for cc=1:passo:size(sceneImage,2)-size(template,2)
        D=template-sceneImage(rr:rr+size(template,1)-1,cc:cc+size(template,2)-1);
        D=mean(abs(D(:)));
        tmp=[tmp D];
    end
    mappa=[mappa; tmp];
end
toc
figure(3), clf, imagesc(mappa), colorbar