clear all;
close all;
clc;

imA = imread('./blend3/apple.jpg');
imB = imread('./blend3/orange.jpg');
imA = im2double(imA);
imB = im2double(imB);
S = size(imA);

N = 8; %numero di livelli della piramide

%% costruzione della piramide gaussiana di A
GA = cell(N);
GA{1} = imA;
for ii = 2:N
    GA{ii, 1} = impyramid(GA{ii-1, 1}, 'reduce');
end
figure(1), clf
for ii = 1:N %plot
    subplot(1, N, ii), imshow(GA{ii, 1})
end

for ii = 2:N %resize
    GA{ii, 1} = imresize(GA{ii, 1}, S(1:2));
end
figure(2), clf
for ii = 1:N %plot
    subplot(1, N, ii), imshow(GA{ii, 1})
end

%% costruzione della piramide gaussiana di B
GB = cell(N);
GB{1, 1} = imB;
for ii = 2:N
    GB{ii, 1} = impyramid(GB{ii-1, 1}, 'reduce');
end
figure(3), clf
for ii = 1:N %plot
    subplot(1, N, ii), imshow(GB{ii, 1})
end

for ii = 2:N %resize
    GB{ii, 1} = imresize(GB{ii, 1}, S(1:2)); 
end
figure(4), clf
for ii = 1:N %plot
    subplot(1, N, ii), imshow(GB{ii, 1})
end

%% costruzione della piramide laplaciana di A
LA = cell(N);
for ii = 1:N-1
    LA{ii, 1} = GA{ii, 1} - GA{ii+1, 1};
end
LA{N} = GA{N};
figure(5), clf
for ii = 1:N
    subplot(1, N, ii), imshow(LA{ii, 1})
end

%% costruzione della piramide laplaciana di B
LB = cell(N);
for ii = 1:N-1
    LB{ii, 1} = GB{ii, 1} - GB{ii+1, 1};
end
LB{N} = GB{N};

figure(6), clf
for ii = 1:N
    subplot(1, N, ii), imshow(LB{ii, 1})
end

%% costruzione della maschera
% sono partito da una maschera con applicato filtraggio gaussiano
% e ho costruito anche la piramite gaussiana della maschera

M = zeros(S);
M(:, 1:210, :) = 1;
F = fspecial('gaussian', 21, 10); 
M = imfilter(M, F, 'same', 'replicate');

%% costruzione della piramide gaussiana di M
GM = cell(N);

GM{1,1} = M;
for ii = 2:N
    GM{ii,1} = impyramid(GM{ii-1,1}, 'reduce');
end

figure(7), clf
for ii = 1:N
    subplot(1, N, ii), imshow(GM{ii,1})
end

for ii = 2:N
    GM{ii,1} = imresize(GM{ii,1}, S(1:2));
end

figure(8), clf
for ii = 1:N
    subplot(1, N, ii), imshow(GM{ii,1})
end

%% blend separatamente di ciascuno dei livelli delle piramidi laplaciane
% (moltiplicando per la maschera del corrispondente livello)
LA_M = cell(N);
for ii = 1:N
    LA_M{ii, 1} = LA{ii, 1} .* GM{ii,1};
end
LB_M = cell(N);
for ii = 1:N
    LB_M{ii, 1} = LB{ii, 1} .* (1-GM{ii,1});
end

%% collassare la piramide laplaciana del risultato

imfinale = imA - imA;       %nuova immagine vuota della grandezza di imA
for ii = 1:N
    imfinale = imfinale + LA_M{N+1 - ii,1} + LB_M{N+1 - ii,1};
    figure(ii+8), imshow(imfinale);
end

imwrite(imfinale, strcat("immagine_finale_" + "N=" + int2str(N) + ".png"));