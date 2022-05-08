clear all;
close all;
clc;
% immagine da individuare
boxImage = imread('./immaginiObjectDetection/elephant.jpg');
% immagine scena
sceneImage = imread('./immaginiObjectDetection/clutteredDesk.jpg');

figure(1), plot(imhist(boxImage));  % non necessario hist eq
figure(2), plot(imhist(sceneImage));    % non necessario hist eq

%% estrazione punti notevoli
boxPoints = detectSURFFeatures(boxImage,MetricThreshold=100, NumOctaves=3, NumScaleLevels=4);
scenePoints = detectSURFFeatures(sceneImage,MetricThreshold=100, NumOctaves=3, NumScaleLevels=4);

% figure(1),clf
% imshow(boxImage), hold on
% plot(selectStrongest(boxPoints,100)), hold off
% 
% figure(2),clf
% imshow(sceneImage), hold on
% plot(selectStrongest(scenePoints,100)), hold off

%% chiamata al descrittore
[boxFeatures,boxPoints]=extractFeatures(boxImage,boxPoints,"Method","SURF");
[sceneFeatures,scenePoints]=extractFeatures(sceneImage,scenePoints,"Method","SURF");

%% match tra features
boxPairs = matchFeatures(boxFeatures,sceneFeatures,MatchThreshold=1.5,Method="Exhaustive");
matchedBoxPoints=boxPoints(boxPairs(:,1),:);
matchedScenePoints=scenePoints(boxPairs(:,2),:);

figure(3), clf
showMatchedFeatures(boxImage,sceneImage,matchedBoxPoints,matchedScenePoints,'montage')

%% pulizia dei match (ransac)
[tform,inlierBoxPoints,inlierScenePoins]=...
    estimateGeometricTransform(matchedBoxPoints,matchedScenePoints,"projective", Confidence=90, MaxDistance=2);

figure(4), clf
showMatchedFeatures(boxImage,sceneImage,inlierBoxPoints,inlierScenePoins,'montage')

%% disegno bbox
% boxPoly=[1 1;
%     size(boxImage,2) 1;
%     size(boxImage,2) size(boxImage,1);
%     1 size(boxImage,1);
%     1 1];
% newBoxPoly=transformPointsForward(tform,boxPoly);
% figure(5),clf
% imshow(sceneImage), hold on
% line(newBoxPoly(:,1),newBoxPoly(:,2),'Color','y')
% hold off


%% disegno punti a mano
% n = 8;
% figure(6), clf, imshow(boxImage)
% [x,y]=ginput(n-1);
% x(n) = x(1);
% y(n) = y(1);
% newBoxPoly_2=transformPointsForward(tform,[x,y]);
% 
% figure(7),clf
% imshow(sceneImage), hold on
% line(newBoxPoly_2(:,1),newBoxPoly_2(:,2),'Color','y')
% hold off

%% disegno automatico con binarization
% x = double.empty;
% y = double.empty;
% pixels = imbinarize(boxImage,'adaptive','ForegroundPolarity','dark','Sensitivity',0.5);
% figure(5), imshow(pixels);
% dims = size(boxImage);
% for i=1:dims(1)
%     for j=1:dims(2)
%         if (not(pixels(i,j)))
%             y = [y; i];
%             x = [x; j];
%         end
%     end
% end
% 
% newBoxPoly_3=transformPointsForward(tform,[x,y]);
% figure(7),clf
% imshow(sceneImage), hold on
% % line(newBoxPoly_3(:,1),newBoxPoly_3(:,2),'Color','y')
% %plot(newBoxPoly_3(:,1),newBoxPoly_3(:,2),'ro', 'MarkerSize', 1);
% scatter1 = scatter(newBoxPoly_3(:,1),newBoxPoly_3(:,2), 'MarkerFaceColor','r','MarkerEdgeColor','k'); 
% alpha(scatter1,.015)
% hold off

%% binarization + convex hull

x = double.empty;
y = double.empty;
pixels = imbinarize(boxImage,'adaptive','ForegroundPolarity','dark','Sensitivity',0.5);
figure(5), imshow(pixels);
dims = size(boxImage);
for i=7:dims(1)     
    for j=1:dims(2)
        if (not(pixels(i,j)))
            y = [y; i];
            x = [x; j];
        end
    end
end

P = [x,y];
convex_hull_pixels = convhull(P);

newBoxPoly_3=transformPointsForward(tform,P);
newBoxPoly_4=transformPointsForward(tform,P(convex_hull_pixels,:));
figure(5),clf
imshow(sceneImage), hold on
line(newBoxPoly_4(:,1),newBoxPoly_4(:,2),'Color','y')
scatter1 = scatter(newBoxPoly_3(:,1),newBoxPoly_3(:,2), 'MarkerFaceColor','r','MarkerEdgeColor','k'); 
alpha(scatter1,.015)
hold off