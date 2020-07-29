% Author: Ahmet Furkan Biyik
% ID: 21501084
% Date: 23.11.2019

% change path of vlfeat toolbox accordingly.
% give path for vl_setup.m file
% run('toolbox/vl_setup'); % to run vlfeat toolbox

% clear
clear;
clc;
close all;

% constants
dataPath = '../data/'; % datapath for image folders
txtPath = '../txt/';
query_images_path = [txtPath 'query_images.txt'];
gallery_images_path = [txtPath 'gallery_images.txt'];
query_labels_path = [txtPath '.query_labels.txt'];
gallery_labels_path = [txtPath 'gallery_labels.txt'];

% construct image databse
imageDatabase = ImageDatabase();

% % =================== generate OR read files ===================
% % select random images from dataset and write them to txt files.
% % use this if you want to generate random query images
% [queryImages, galleryImages, queryLabels, galleryLabels] = ImageDatabase.createRandomImages(dataPath, txtPath);
% 
% % read image path and label files and assign queryImages, galleryImages, 
% % queryLabels and galleryLabels.
% % use this if you want to read txt path and label files
[queryImages, galleryImages, queryLabels, galleryLabels] = ImageDatabase.readFiles(query_images_path, gallery_images_path, query_labels_path, gallery_labels_path);
% % ==============================================================

% creeate database
imageDatabase = imageDatabase.createDatabase( galleryImages, galleryLabels);

% analyze
table = zeros(6,11); % for table
means = {}; % for means for different types

% evaluate
% % =================== single evaluation ===================
% % to evaluate for single descriptor and codebook size run following
% % code with different type.         
% % type= 1: gradient size = 500,
% %       2: gradient size = 1000
% %       3: color size = 500
% %       4: color size = 1000
% %       5: combined size = 500
% %       6: combined size = 1000
% [singleMeans, singleK10Scores] = imageDatabase.evaluate(queryImages, queryLabels, type);
% figure;
% plot(singleMeans);
% 
% % set labels
% if type < 3
%     descStr = 'Gradient';
% elseif type < 5
%     descStr = 'Color';
% else
%     descStr = 'Combined';
% end
% 
% if mod(type, 2) == 1
%     title(sprintf('K-menas K: %d, Descriptor: %s', FeaturedImage.k1, descStr));
% else
%     title(sprintf('K-menas K: %d, Descriptor: %s', FeaturedImage.k2, descStr));
% end
% 
% xlabel('K');
% 
% % show table
% array2table(singleK10Scores, 'VariableNames', {'africa','beach','buildings','buses','dimosaurs','elephants','flowers','horses','mountains','food','overall'})
% % =================== end of single evaluation ===================


% evaluate all
figure;
for type = 1 : 6
    [means{type}, K10Scores] = imageDatabase.evaluate(queryImages, queryLabels, type);
    
    subplot(2,3, type);
    plot(means{type});
    table(type, :) = K10Scores;

    % set labels
    if type < 3
        descStr = 'Gradient';
    elseif type < 5
        descStr = 'Color';
    else
        descStr = 'Combined';
    end

    if mod(type, 2) == 1
        title(sprintf('K-menas K: %d, Descriptor: %s', FeaturedImage.k1, descStr));
    else
        title(sprintf('K-menas K: %d, Descriptor: %s', FeaturedImage.k2, descStr));
    end

    xlabel('K');
end

% show table
array2table(table, 'VariableNames', {'africa','beach','buildings','buses','dimosaurs','elephants','flowers','horses','mountains','food','overall'})
