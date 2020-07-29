% Author: Ahmet Furkan Biyik
% ID: 21501084
% Date: 23.11.2019

% use this script to search individual image
% use this after database created 
% to create database use entryPoint.m

% image index to search
% this is for queryImages array
im = 95; 

% search image
searchIm = imageDatabase.createImageData( string(queryImages(im)), queryLabels(im));
result = imageDatabase.nearestNeigborSearch(searchIm, 5);

% show searched image
figure;
imshow(imread(string(queryImages(im))));
title(string(queryImages(im)));

% show relevant images
figure;
for i = 1:10
   
    subplot(2,5,i);
    imshow( imread(imageDatabase.database(result(i)).path));
    

end
