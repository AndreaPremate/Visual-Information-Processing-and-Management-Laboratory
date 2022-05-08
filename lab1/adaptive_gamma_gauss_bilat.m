clear all;
close all;
clc;

im = imread('underexposed.jpg');

im = im2double(im); % valori in double tra [0,1]
im_Ycbcr = rgb2ycbcr(im);
canaleY = im_Ycbcr(:,:,1)*255; % double in [0 255] come "input" dell'articolo

% Y filtro gauss
F = fspecial('gaussian',51,21);
Yfiltrato_gauss = imfilter(canaleY,F,'same','replicate');

% Y filtro bilaterale
Yfiltrato_bilat = imbilatfilt(canaleY/255,0.5,3);

% im rgb gauss
im_Ycbcr_gauss = im_Ycbcr;
im_Ycbcr_gauss(:,:,1)=Yfiltrato_gauss/255;
im_rgb_gauss=ycbcr2rgb(im_Ycbcr_gauss);

% im rgb bilat
im_Ycbcr_bilat = im_Ycbcr;
im_Ycbcr_bilat(:,:,1) = Yfiltrato_bilat;
im_rgb_bilat = ycbcr2rgb(im_Ycbcr_bilat);

% alcuni plot
figure(1),clf
imshow(im), title('rgb originale')

figure(2), clf
subplot(1,2,1), imshow(im_rgb_gauss), title('rgb con Y filtrato con gauss')
subplot(1,2,2), imshow(im_rgb_bilat), title('rgb con Y filtrato bilaterale')

figure(3), clf
subplot(1,3,1), imshow(canaleY/255), title('Y originale')
subplot(1,3,2), imshow(Yfiltrato_gauss/255), title('Y filtro gauss')
subplot(1,3,3), imshow(abs(canaleY/255 - Yfiltrato_gauss/255)), title('abs(Y orig - Y gauss)')

figure(4), clf
subplot(1,3,1), imshow(canaleY/255), title('Y originale')
subplot(1,3,2), imshow(Yfiltrato_bilat), title('Y filtro bilaterale')
subplot(1,3,3), imshow(abs(canaleY/255 - Yfiltrato_bilat)), title('abs(Y orig - Y bilat)')


%%% implementazione eq1

%%       GAUSS
mask_gauss = 1.-Yfiltrato_gauss/255;

figure(5), clf
imshow(mask_gauss), title('Y filtrato gauss (NEG)')

% eq1 su Y
finalimageY_gauss = 255*(canaleY./255).^(2.^((128.-mask_gauss*255)./128));
figure(6), clf
imshow(finalimageY_gauss/255), title('Y adaptive gamma gauss filt')

im_Ycbcr_gauss(:,:,1) = finalimageY_gauss/255;
adapgammaRGB_gauss = ycbcr2rgb(im_Ycbcr_gauss); 
figure(7), clf
imshow(adapgammaRGB_gauss), title('RGB with Y adaptive gamma gauss filt')

%%       BILAT
mask_bilat = 1.-Yfiltrato_bilat;

figure(8), clf
imshow(mask_bilat), title('Y filtrato bilaterale (NEG)')

% eq1 su Y
finalimageY_bilat = 255*(canaleY./255).^(2.^((128.-mask_bilat*255)./128));
figure(9), clf
imshow(finalimageY_bilat/255), title('Y adaptive gamma bilateral filt')

im_Ycbcr_bilat(:,:,1) = finalimageY_bilat/255;
adapgammaRGB_bilat = ycbcr2rgb(im_Ycbcr_bilat); 
figure(10), clf
imshow(adapgammaRGB_bilat), title('RGB with Y adaptive gamma bilateral filt')
%%

% differenze tra canale Y orig e adp gamma con gauss e bilat 
figure(11), clf
subplot(1,2,1), imshow(abs(canaleY/255 - finalimageY_gauss/255)), title('abs(canaleY - finalimageY gauss)')
subplot(1,2,2), imshow(abs(canaleY/255 - finalimageY_bilat/255)), title('abs(canaleY - finalimageY bilat)')


