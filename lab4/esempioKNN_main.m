clear all
clc
close all

Nim4training=70; % split 70-30
Nbins=8;
features=[];
labels=[];
%% ciclo sul training
tic
for class=0:9
    for nimage=0:Nim4training-1
        % disp([num2str(class) '-' num2str(nimage)]);
        im = imread(['./simplicityDB/image.orig/' num2str(100*class+nimage) '.jpg']);
        im = im2double(im);
        %im = rgb2hsv(im);
        im = rgb2ycbcr(im);
        upperLeft = im(1:floor(size(im,1)/2), 1:floor(size(im,2)/2), :);
        upperRight = im(1:floor(size(im,1)/2), floor(size(im,2)/2)+1:end, :);
        lowerLeft = im(floor(size(im,1)/2)+1:end, 1:floor(size(im,2)/2), :);
        lowerRight = im(floor(size(im,1)/2)+1:end, floor(size(im,2)/2)+1:end, :);
        % im = reshape(im, [], 3); % sulle 3 colonne abbiamo ora i 3 canali colore RGB
        upperLeft = reshape(upperLeft, [], 3);
        upperRight = reshape(upperRight, [], 3);
        lowerLeft = reshape(lowerLeft, [], 3);
        lowerRight = reshape(lowerRight, [], 3);
        % f = mean(im); % 3 valori, fa media sulle righe come serve a noi
        %f = [mean(im) std(im)]; % 6 valori
        %f = [mean(upperLeft) std(upperLeft) mean(upperRight) std(upperRight) mean(lowerLeft) std(lowerLeft) mean(lowerRight) std(lowerRight)]; 
        f = [calcoloIstogramma(upperLeft,Nbins) calcoloIstogramma(upperRight,Nbins) calcoloIstogramma(lowerLeft,Nbins) calcoloIstogramma(lowerRight,Nbins)]; 
        %f = [f mean(im) std(im)]; % var(im) kurtosis(im) skewness(im)
        features = [features; f];
        labels = [labels; class];
    end
end
toc

%% ciclo sul test

features_te=[];
labels_te=[];
tic
for class=0:9
    for nimage=Nim4training:99
        % disp([num2str(class) '-' num2str(nimage)]);
        im = imread(['./simplicityDB/image.orig/' num2str(100*class+nimage) '.jpg']);
        im = im2double(im);
        %im = rgb2hsv(im);
        im = rgb2ycbcr(im);
        upperLeft = im(1:floor(size(im,1)/2), 1:floor(size(im,2)/2), :);
        upperRight = im(1:floor(size(im,1)/2), floor(size(im,2)/2)+1:end, :);
        lowerLeft = im(floor(size(im,1)/2)+1:end, 1:floor(size(im,2)/2), :);
        lowerRight = im(floor(size(im,1)/2)+1:end, floor(size(im,2)/2)+1:end, :);
        %im = reshape(im, [], 3); % sulle 3 colonne abbiamo ora i 3 canali colore RGB
        upperLeft = reshape(upperLeft, [], 3);
        upperRight = reshape(upperRight, [], 3);
        lowerLeft = reshape(lowerLeft, [], 3);
        lowerRight = reshape(lowerRight, [], 3);
        
        % f = mean(im); % 3 valori, fa media sulle righe come serve a noi
        %f = [mean(im) std(im)]; % 6 valori
        %f = [mean(upperLeft) std(upperLeft) mean(upperRight) std(upperRight) mean(lowerLeft) std(lowerLeft) mean(lowerRight) std(lowerRight)]; 
        %f = calcoloIstogramma(im,Nbins); % Nbins*3 valori
        f = [calcoloIstogramma(upperLeft,Nbins) calcoloIstogramma(upperRight,Nbins) calcoloIstogramma(lowerLeft,Nbins) calcoloIstogramma(lowerRight,Nbins)]; 
        %f = [f mean(im) std(im)];
        features_te = [features_te; f];
        labels_te = [labels_te; class];
    end
end
toc


%% costruzione del classificatore
% k-nn con k=1 e distanza euclidea
labels_pred = [];
for ns=1:size(features_te,1)
%     d = sqrt(sum((features_te(ns,:)- features).^2,2)); euclidean dist
%     u = find(d==min(d));
%     u = u(1);
    min = inf;
    for ns2=1:size(features,1)
        %d = ws_distance(features_te(ns,:), features(ns2,:), 1);
        d = pdist([features_te(ns,:); features(ns2,:)], 'spearman');
        
        %% chisquare distance
%         somma = 0;
%         for ii=1:size(f,2)
%             if (features_te(ns,ii) + features(ns2,ii)==0)
%                 somma = somma;
%             else
%                 somma = somma + ((features_te(ns,ii) - features(ns2,ii)).^2)./(features_te(ns,ii) + features(ns2,ii));
%             end
%         end
%         d = 0.5 * somma; %inutile
        %% stop chisquare
        
        if d < min
            min = d;
            u = ns2;
        end
    end

    labels_pred = [labels_pred; labels(u)];
end

%% calcolo performance
M=confusionmat(labels_te,labels_pred);
M= M./sum(M,2);
acc = mean(diag(M))


