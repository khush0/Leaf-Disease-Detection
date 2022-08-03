clc
clear all
close all
[f,p] = uigetfile('*.*');

if f == 0
    
    warndlg('You Have Cancelled.....');
    
else

I = imread([p f]);

figure('name','Input image');

imshow(I);  % Display input image

title('Input Image','FontName','Times New Roman');
end

load('estimated_ill_test.mat');

l_e = reshape(double(l_e),[],3);

l_e = l_e./norm(l_e);

opt = 1; %use [1] Matlab rgb2xyz function (Ebner, Marc. "Color Constancy") or [2] Matthew Anderson "Proposal for a Standard Default Color Space for the Internet—sRGB"

out = chrom_adapt(im2double(I), l_e, opt,'cat2000',1);  %'xyzscalling', 'bradford', 'von', 'sharp', or 'cat2000'
figure;
subplot(1,2,1); imshow(I); title('Input image'); 
subplot(1,2,2); imshow(out); title('Corrected image');%I = imresize(I,[256 256]);
IG=rgb2gray(out);
figure,imshow(IG);
level = graythresh(IG)
BW = im2bw(out,level);
figure,imshow(BW);
se = strel('disk',40);
openBW = imopen(BW,se);
figure, imshow(openBW);
bin_img = 255 * repmat(uint8(openBW), 1, 1, 3);
fin_img=I+bin_img;
figure, imshow(fin_img);

