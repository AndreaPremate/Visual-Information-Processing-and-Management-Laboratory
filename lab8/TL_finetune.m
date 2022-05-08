%
% le accuracy ottenute su diverse run sono di [95-97.33]
%

close all;
clear all;
clc;

net=alexnet;
sz=net.Layers(1).InputSize;

%% cut layers
layersTransfer=net.Layers(1:end-3);
layersTransfer=freezeWeights(layersTransfer); 

%% replace layers
numClasses=10;
layers=[
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',10,...
    'BiasLearnRateFactor',10)
    softmaxLayer
    classificationLayer];

%% data preparation
imds=imageDatastore('image.orig/');
labels=[];
for ii=1:size(imds.Files,1)
    name=imds.Files{ii,1};
    [p,n,ex]=fileparts(name);
    class=floor(str2double(n)/100);
    labels=[labels; class];
end
labels=categorical(labels);
imds=imageDatastore('image.orig/','labels',labels);

%% divisione train-test
[imdsTrain,imdsTest]=splitEachLabel(imds,0.7,'randomized');

%% data augmentation
pixelRange=[-40 40];
imageAugmenter=imageDataAugmenter(... % 
    'FillValue', [0 0 0],...
    'RandXReflection',true,...
    'RandXTranslation',pixelRange,...
    'RandYTranslation',pixelRange,...
    'RandRotation', [-30 30],...   
    'RandScale', [0.7 1.3], ...
    'RandYShear', [-10 10]);

augImdsTrain=augmentedImageDatastore(sz(1:2),imdsTrain,'DataAugmentation',imageAugmenter);
augImdsTest= augmentedImageDatastore(sz(1:2),imdsTest);

%% configurazione finetuning
options=trainingOptions('sgdm',...
    'MiniBatchSize',10,...
    'MaxEpochs',5,...
    'InitialLearnRate',1e-4,...
    'Shuffle','every-epoch',...
    'ValidationData',augImdsTest,...
    'ValidationFrequency',3,...
    'Verbose',false,...
    'Plots','training-progress',...  'L2Regularization',0.0001,...
    'ExecutionEnvironment', 'auto',...
    'OutputNetwork','best-validation-loss');

%% training vero e proprio
netTransfer=trainNetwork(augImdsTrain,layers,options);

[lab_pred_te,scores]=classify(netTransfer,augImdsTest);
acc=numel(find(lab_pred_te==imdsTest.Labels))/numel(lab_pred_te)