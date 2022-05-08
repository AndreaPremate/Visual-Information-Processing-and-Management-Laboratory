clear all;
close all;
clc;

im1 = imread('./colorTransfer/image1.png'); % contenuto
im2 = imread('./colorTransfer/image2.png'); % colore

im1 = im2double(im1);
im2 = im2double(im2);
im1_orig = im1;

im1 = rgb2ycbcr(im1);
im2 = rgb2ycbcr(im2);

% calcolo la media di cb e cr di im1 e im2
S1 = size(im1);
S2 = size(im2);

im1 = reshape(im1, [], 3);
im2 = reshape(im2, [], 3);

figure(1), clf
subplot(1,3,1), plot(im1(:,2), im1(:,3), '.'), xlim([0 1]), ylim([0 1])
subplot(1,3,2), plot(im2(:,2), im2(:,3), '.'), xlim([0 1]), ylim([0 1])

medie1 = mean(im1);
medie2 = mean(im2);
std1 = std(im1);
std2 = std(im2);

% devo trasformare la media di im1 im modo che sia uguale a quella di im2
% 
% im1(:, 2) = im1(:, 2) - (medie1(2) - medie2(2));
% im1(:, 3) = im1(:, 3) - (medie1(3) - medie2(3));
% nuoveMedie1 = mean(im1);
% subplot(1,3,3), plot(im1(:,2), im1(:,3), '.'), xlim([0 1]), ylim([0 1])

% devo trasformare la media e std di im1 tali che siano quelle di im2
% im1(:, 2) = im1(:, 2) - medie1(2);
% im1(:, 3) = im1(:, 3) - medie1(3);
% im1(:, 2) = im1(:, 2) / std1(2);
% im1(:, 3) = im1(:, 3) / std1(3);



for ch = 2:3
    im1(:,ch) = im1(:,ch) - medie1(ch);
    im1(:,ch) = im1(:,ch) ./ std1(ch);
    im1(:,ch) = im1(:,ch) .* std2(ch);
    im1(:,ch) = im1(:,ch) + medie2(ch);
end
subplot(1,3,3), plot(im1(:,2), im1(:,3), '.'), xlim([0 1]), ylim([0 1])

nuoveMedie1 = mean(im1);
nuoveStd1 = std(im1);

% risistemo le immagini
im1 = reshape(im1, S1);
im2 = reshape(im2, S2);
im1 = ycbcr2rgb(im1);
im2 = ycbcr2rgb(im2);

%visualizzo il risultato
figure(2), clf
subplot(1,3,1), imshow(im1_orig)
subplot(1,3,2), imshow(im1)
subplot(1,3,3), imshow(im2)







