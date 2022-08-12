clc
clear
close all
%% loading data
load(fullfile(pwd,'PhysionetDataset\physionet_ECG_data_main','ECGData.mat'))
%% Seperate Classes
parentDir = pwd;
dataDir = 'data';
CreateECGDirectories(ECGData,parentDir,dataDir)
%% Visualization
SamplePlotReps(ECGData)
%% Create Time-Frequency Representations - Scalogram -CWT
Fs = 128;
fb = cwtfilterbank('SignalLength',1000,...
    'SamplingFrequency',Fs,...
    'VoicesPerOctave',12);
Signal = ECGData.Data(1,1:1000);
[cfs,frq] = wt(fb,Signal);
time = (0:999)/Fs;figure;pcolor(time,frq,abs(cfs))
set(gca,'yscale','log');shading interp;axis tight;
title('Scalogram');xlabel('Time (s)');ylabel('Frequency (Hz)')
%% Create the Scalograms as RGB Images and Write them to the appropriate subdirectory
CreateRGBfromTF(ECGData,parentDir,dataDir)
%% Creating Image dataset and Divide into Training and Validation Data
ImageDs = imageDatastore(fullfile(parentDir,dataDir),...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');

[imgsTrain,imgsValidation] = splitEachLabel(ImageDs,0.8,'randomized');
disp(['Number of training images: ',num2str(numel(imgsTrain.Files))]);
disp(['Number of validation images: ',num2str(numel(imgsValidation.Files))]);
%% Pretrained Network
net = googlenet;

lgraph = layerGraph(net);
numberOfLayers = numel(lgraph.Layers);
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph)
title(['GoogLeNet Layer Graph: ',num2str(numberOfLayers),' Layers']);

%% Modification
newDropoutLayer = dropoutLayer(0.6,'Name','new_Dropout');
lgraph = replaceLayer(lgraph,'pool5-drop_7x7_s1',newDropoutLayer);
numClasses = numel(categories(imgsTrain.Labels));
% Replace the fully connected layer
newConnectedLayer = fullyConnectedLayer(numClasses,'Name','new_fc',...
    'WeightLearnRateFactor',5,'BiasLearnRateFactor',5);
lgraph = replaceLayer(lgraph,'loss3-classifier',newConnectedLayer);

newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'output',newClassLayer);

%% Options
options = trainingOptions('sgdm',...
    'MiniBatchSize',15,...
    'MaxEpochs',20,...
    'InitialLearnRate',1e-4,...
    'ValidationData',imgsValidation,...
    'ValidationFrequency',10,...
    'Verbose',1,...
    'ExecutionEnvironment','cpu',...
    'Plots','training-progress');

%% Lets Train!
TrainedNet = trainNetwork(imgsTrain,lgraph,options);
%% Evaluation
[YPred,probs] = classify(TrainedNet,imgsValidation);
accuracy = mean(YPred==imgsValidation.Labels);
disp(['GoogLeNet Accuracy: ',num2str(100*accuracy),'%'])
%% FC Layer Weights
wghts = TrainedNet.Layers(2).Weights;
wghts = rescale(wghts);
wghts = imresize(wghts,5);
figure
montage(wghts)
title('First Convolutional Layer Weights')
exportgraphics(gca,'fclayerwght.png','ContentType','image','Resolution',480)

%% Examine which areas in the convolutional layers activate on an image from the ARR class
convLayer = 'conv1-7x7_s2';

imgClass = 'ARR';
imgName = 'ARR_10.jpg';
imarr = imread(fullfile(parentDir,dataDir,imgClass,imgName));

trainingFeaturesARR = activations(TrainedNet,imarr,convLayer);
sz = size(trainingFeaturesARR);
trainingFeaturesARR = reshape(trainingFeaturesARR,[sz(1) sz(2) 1 sz(3)]);
figure
montage(rescale(trainingFeaturesARR),'Size',[8 8])
title([imgClass,' Activations'])
exportgraphics(gca,'ARRactivations.png','ContentType','image','Resolution',480)
%% Find the strongest channel for this image
imgSize = size(imarr);
imgSize = imgSize(1:2);
[~,maxValueIndex] = max(max(max(trainingFeaturesARR)));
arrMax = trainingFeaturesARR(:,:,:,maxValueIndex);
arrMax = rescale(arrMax);
arrMax = imresize(arrMax,imgSize);
figure;
imshowpair(imarr,arrMax,'montage')
title(['Strongest ',imgClass,' Channel: ',num2str(maxValueIndex)])
exportgraphics(gca,'Compare.png','ContentType','image','Resolution',720)
