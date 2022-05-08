clear all;
close all;
clc;

% immagini pupazzo
% imFlash = imread('./flash-noflash/giantShadowFlash.jpg');
% imNoFlash = imread('./flash-noflash/giantShadowNo-flash.jpg');

%immagini torta
imFlash = imread('./flash-noflash/cakeFlash.jpg');
imNoFlash = imread('./flash-noflash/cakeNo-flash.jpg');

imFlash = im2double(imFlash);
imNoFlash = im2double(imNoFlash);

imFlash_ycbcr = rgb2ycbcr(imFlash);
imNoFlash_ycbcr = rgb2ycbcr(imNoFlash);

NOFLASH_intensity_largescale = imbilatfilt(imNoFlash_ycbcr(:,:,1),0.1,15);
figure(1), imshow(NOFLASH_intensity_largescale);

FLASH_color = imFlash_ycbcr(:,:,2:3);
FLASH_intensity_details = imFlash_ycbcr(:,:,1) - imbilatfilt(imFlash_ycbcr(:,:,1),0.1,15);
figure(2), 
subplot(1,2,1), imshow(FLASH_color(:,:,1));
subplot(1,2,2), imshow(FLASH_color(:,:,2));
figure(3), imshow(FLASH_intensity_details);

FINAL_intensity = NOFLASH_intensity_largescale + FLASH_intensity_details;
figure(4), imshow(FINAL_intensity);

FINAL_ycbcr(:,:,1) = FINAL_intensity;
FINAL_ycbcr(:,:,2:3) = FLASH_color;
FINAL_rgb = ycbcr2rgb(FINAL_ycbcr);
figure(5), imshow(FINAL_rgb);

%imwrite(FINAL_rgb, strcat("giantShadow" + "Final" +".png"));
imwrite(FINAL_rgb, strcat("cake" + "Final" +".png"));
