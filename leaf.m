%this code developed by TJ idea for innovation
clc
close all 
clear all

[filename, pathname] = uigetfile({'*.*';'*.bmp';'*.jpg';'*.gif'}, 'Pick a Leaf Image File');
I = imread([pathname,filename]);
figure, imshow(I); title('Query  Image');

% Enhance Contrast
I = imadjust(I,stretchlim(I));
figure, imshow(I);title('Contrast Enhanced');

% Color Image Segmentation
% Use of K Means clustering for segmentation
% Convert Image from RGB Color Space to L*a*b* Color Space 
 %this code developed by TJ idea for innovation
% The L*a*b* space consists of a luminosity layer 'L*', chromaticity-layer 'a*' and 'b*'.
% All of the color information is in the 'a*' and 'b*' layers.
cform = makecform('srgb2lab');
% Apply the colorform
lab_he = applycform(I,cform);

% Classify the colors in a*b* colorspace using K means clustering.
% Since the image has 3 colors create 3 clusters.
%this code developed by TJ idea for innovation
% Measure the distance using Euclidean Distance Metric.
ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
%[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% Label every pixel in tha image using results from K means
pixel_labels = reshape(cluster_idx,nrows,ncols);
%figure,imshow(pixel_labels,[]), title('Image Labeled by Cluster Index');

% Create a blank cell array to store the results of clustering
segmented_images = cell(1,2);
% Create RGB label using pixel_labels
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end



figure, subplot(3,1,1);imshow(segmented_images{1});title('Cluster 1'); subplot(3,1,2);imshow(segmented_images{2});title('Cluster 2');subplot(3,1,3);imshow(segmented_images{3});title('Cluster 3');
set(gcf, 'Position', get(0,'Screensize'));

% Feature Extraction
x = inputdlg('Enter the cluster no. containing the ROI only:');
i = str2double(x);
% Extract the features from the segmented image
seg_img = segmented_images{i};
figure,imshow(seg_img);
seg_imggray=rgb2gray(seg_img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
glcms = graycomatrix(seg_imggray);
% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hsvIm = rgb2hsv(seg_img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    IFE=seg_img;
    R = double(IFE(:, :, 1));
G = double(IFE(:, :, 2));
B = double(IFE(:, :, 3));

meanR = mean( R(:) );
stdR  = std( R(:) );
meanG = mean( G(:) );
stdG  = std( G(:) );
meanB = mean( B(:) );
stdB  = std( B(:) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rn=meanR/(meanR+meanG+meanB);
Gn=meanG/(meanR+meanG+meanB);
Bn=meanB/(meanR+meanG+meanB);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Radd=(Rn-Bn)*(Rn-Gn);
Gadd=(Gn-Rn)*(Gn-Bn);
Badd=(Bn-Gn)*(Bn-Rn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colorMoments = zeros(1,13);
colorMoments = [meanR stdR meanG stdG meanB stdB Rn Gn Bn Radd Gadd Badd];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hsvImage=hsvIm;
meanHue = mean2(hsvImage(:,:,1))
meanSat = mean2(hsvImage(:,:,2))
meanValue = mean2(hsvImage(:,:,3))
sdImage = stdfilt(hsvImage(:,:,3)); % Std Deviation of Value channel.
meanStdDev = mean2(sdImage);
featureVector = [meanHue, meanSat, meanValue, meanStdDev];
%%%%%%%%%%%%%%%%%%%%%%%%%%%
Kurtosis = kurtosis(double(seg_img(:)));
Skewness= skewness(double(seg_img(:)));

clear('R', 'G', 'B', 'meanR', 'stdR', 'meanG', 'stdG', 'meanB', 'stdB');
Testfea=[Contrast Correlation Energy Homogeneity colorMoments featureVector Kurtosis(1,1) Skewness(1,1)]; 
save Testfea Testfea