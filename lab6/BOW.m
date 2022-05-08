clear all;
close all;

%% creazione della griglia
disp('creazione griglia')
pointPositions=[];
featStep=10; 
imsize=500;
for ii=featStep:featStep:imsize-featStep
    for jj=featStep:featStep:imsize-featStep
        pointPositions=[pointPositions; ii jj];
    end
end

%%
disp('estrazione features')
Nim4training=70;
features=[];
labels=[];
tic
for class=0:9
    for nimage=0:Nim4training-1
        im=im2double(imread(['simplicityDB/image.orig/' num2str(100*class+nimage) '.jpg']));
        im=imresize(im,[imsize imsize]);
        im=rgb2gray(im);
        [imfeatures,dontcare]=extractFeatures(im,pointPositions,'Method','SURF');
        features=[features; imfeatures];
        labels=[labels; repmat(class,size(imfeatures,1),1) repmat(nimage,size(imfeatures,1),1)];
    end
end
toc

%% 
disp('creazione vocabolario')
K=80;
tic
[IDX,C]=kmeans(features,K,MaxIter=100, Distance="sqeuclidean");
toc

%%
disp('rappresentazione BOW training')
BOW_tr=[];
labels_tr=[];
tic
for class=0:9
    for nimage=0:Nim4training-1
        u=find(labels(:,1)==class & labels(:,2)==nimage);
        imfeaturesIDX=IDX(u);
        H=hist(imfeaturesIDX,1:K);
        H=H./sum(H);
        BOW_tr=[BOW_tr; H];
        labels_tr=[labels_tr; class];
    end
end
toc

%% adddestramento classificatore
% usando BOW_tr e labels_tr

[coeff,score_tr,~,~,explained,mu] = pca(BOW_tr);
idd = find(cumsum(explained)>99,1);
BOW_tr_PCA = score_tr(:,1:idd);
mdl = fitcnb(BOW_tr_PCA, labels_tr);

% si è provato a usare anche una rete, ottimizzata appositamente per il
% numero di epochs, ma i risultati variano maggiormente a causa
% dell'inizializzazione random del k-means (anche il naive bayes viene
% influenzato da ciò) e dei parametri della rete. Facendo diverse run si
% è visto che l'accuracy varia in un intervallo di 60-75%.
% I decision tree invece restituiscono performance intorno al 50%.
% mdl = fitcnet(BOW_tr_PCA, labels_tr,'IterationLimit',1200);

%%
disp('rappresentazione BOW test')
BOW_te=[];
labels_te=[];
tic
for class=0:9
    for nimage=Nim4training:99
        im=im2double(imread(['simplicityDB/image.orig/' num2str(100*class+nimage) '.jpg']));
        im=imresize(im,[imsize imsize]);
        im=rgb2gray(im);
        [imfeatures,dontcare]=extractFeatures(im,pointPositions,'Method','SURF');
        %%%
        D=pdist2(imfeatures,C,"squaredeuclidean");
        [dontcare,words]=min(D,[],2);
        %%%
        H=hist(words,1:K);
        H=H./sum(H);
        BOW_te=[BOW_te; H];
        labels_te=[labels_te; class];
    end
end
toc

%% classificazione del test set

BOW_te_PCA = (BOW_te-mu)*coeff(:,1:idd);
predicted_class = predict(mdl,BOW_te_PCA);

%% misurazione performance
CM=confusionmat(labels_te,predicted_class);
CM=CM./repmat(sum(CM,2),1,size(CM,2))
accuracy = mean(diag(CM))
