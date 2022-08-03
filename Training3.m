for iii =1:85
   iii
I = imread(['C:\Users\Khush\Desktop\leaf dis\',num2str(iii),'.jpg']);
 I = imadjust(I,stretchlim(I));
 %I = imadjust(I,[.0 .0 0; .3 .7 1],[]);
figure, imshow(I);title('Contrast Enhanced');

cform = makecform('srgb2lab');
lab_he = applycform(I,cform);

ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);

segmented_images = cell(1,3);
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

seg_img = segmented_images{i};
seg_imggray=rgb2gray(seg_img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
glcms = graycomatrix(seg_imggray);
% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% Mean = mean2(seg_img);
% Standard_Deviation = std2(seg_img);
% Entropy = entropy(seg_img);
% RMS = mean2(rms(seg_img));
% Variance = mean2(var(double(seg_img)));
% a = sum(double(seg_img(:)));
% Smoothness = 1-(1/(1+a));
% % Inverse Difference Movement
% m = size(seg_img,1);
% n = size(seg_img,2);
% in_diff = 0;
% for i = 1:m
%     for j = 1:n
%         temp = seg_img(i,j)./(1+(i-j).^2);
%         in_diff = in_diff+temp;
%     end
% end
% IDM = double(in_diff);

clear('R', 'G', 'B', 'meanR', 'stdR', 'meanG', 'stdG', 'meanB', 'stdB');
Trainfea(iii,:)=[Contrast Correlation Energy Homogeneity colorMoments featureVector Kurtosis(1,1) Skewness(1,1)]; 
close all;
end
save Trainfea Trainfea