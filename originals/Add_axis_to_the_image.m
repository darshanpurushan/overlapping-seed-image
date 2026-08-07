%code  to add the axis to each image to the image captured from the scanner
%developed by Yogeshwaran. G on 19/9//2022
clear all
clc
close all
tic
axis = imread('C:\Users\purus\Pictures\Scans\Axis_image.png');
[L,B]=size(rgb2gray(axis));
ymin = 1666; %minimum y value for adding to the image
ymax = 3106; %maximum y value for adding to the image 
diff = ymax-ymin;
imgfiles=dir('*.png'); %takes all the images in the directory as one structure
N=length(imgfiles);

%%
%Add axis to the each image

 for i=1:N
    K = imgfiles(i).name; 
    K1 = K(1:4);  
    K1(5:9) = 'A.png'; 
    CC = imread(imgfiles(i).name); %start reading from second image because first image corresponds to background
    CC(L-diff:L,1:B,:)=axis(ymin:ymax,1:B,:);
    imwrite(CC,K1);
end
 