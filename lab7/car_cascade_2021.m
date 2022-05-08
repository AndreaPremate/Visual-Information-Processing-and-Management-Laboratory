clear all;
close all;
clc;

% commento: per semplicità di gestione gli esempi positivi e negativi sono 
% stati separati in cartelle distinte

path_v = [];
p_v = [];
Nim4training=550;
for nimage=0:Nim4training-1
    path = "./CarDataset/TrainImages/pos/pos-" + num2str(nimage) + ".pgm";
    
    p = [1,1,100,40];
    p_v = [p_v ; p];
    path_v = [path_v; path];
end
path_v = convertStringsToChars(path_v);
positiveInstances = table(path_v,p_v,'VariableNames',{'imageFilename','posizione'});

% trasformazione immagini dataset simplicity da rgb a grayscale
creaGrayscale = false;
if ~exist("./image.orig_grayscale/", 'dir')
       mkdir("./image.orig_grayscale/")
       creaGrayscale = true;
end
if (creaGrayscale)
    for i=0:999
        path_im = "./image.orig/" + num2str(i) + ".jpg";
        im = imread(path_im);
        im = rgb2gray(im);
        path_im_grayscale = "./image.orig_grayscale/" + num2str(i) + ".jpg";
        imwrite(im, path_im_grayscale);
    end
end

negativeImages = imageDatastore({'./CarDataset/TrainImages/neg','./image.orig_grayscale'});

%% train
trainCascadeObjectDetector('cars.xml',...
    positiveInstances,negativeImages,'FalseAlarmRate',0.1,'NumCascadeStages',5);

%% detector
detector = vision.CascadeObjectDetector('C:/Users/andrea1/Desktop/Visual information processing and management/esercitazione7/cars.xml');

%% risultati

% calcolo bbox su tutte img test
if ~exist("./TestImages_bbox/", 'dir')
       mkdir("./TestImages_bbox/")
end
for i=0:169
        path_img = "./CarDataset/TestImages/test-" + num2str(i) + ".pgm";
        img = imread(path_img);
        bbox = detector(img);
        if not(isempty(bbox))
            detectedImg=insertObjectAnnotation(img,'rectangle',bbox,'car');
        end
        imwrite(detectedImg,"./TestImages_bbox/test_bbox-" + num2str(i) + ".pgm")
end

% esempio per plot
img = imread('./CarDataset/TestImages/test-0.pgm');
bbox = detector(img);
if not(isempty(bbox))
    detectedImg=insertObjectAnnotation(img,'rectangle',bbox,'car');
end
figure(1),clf,imshow(detectedImg)
imwrite(detectedImg,'esepioCarDet.jpg')