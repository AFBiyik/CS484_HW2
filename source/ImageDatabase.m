% Author: Ahmet Furkan Biyik
% ID: 21501084
% Date: 23.11.2019

classdef ImageDatabase
    %ImageDatabase database for images with features
    
    properties
        database; % ImageData array
        codebooks; % kmeans centers
    end
    
    methods
        function obj = ImageDatabase()
            %ImageDatabase Constructor
            obj.codebooks = cell(1,6);
        end
        
        function [obj] = createDatabase(obj, galleryImages, galleryLabels)
        %createDatabase creates database
        %   db = db.createDatabase( galleryImages, galleryLabels)
        %   galleryImages: cell array of string image paths
        %   galleryLabels: array of labels
        %   galleryImages and galleryLabels must have same size

            dbSize = size(galleryImages,2);

            % create empty arrays
            featuredImageDB(1, dbSize) = FeaturedImage;
            db(1, dbSize) = ImageData;

            % init each image
            for i = 1:dbSize
                featuredImageDB( i ) = FeaturedImage(string(galleryImages(i)), galleryLabels(i));
            end

            % combine descriptor
            descriptorData = featuredImageDB(1).gradientDescriptor;
            for i = 2 : dbSize
                descriptorData = [descriptorData featuredImageDB(i).gradientDescriptor];
            end

            descriptorData = transpose(descriptorData);
            descriptorData = downsample(descriptorData,30); % subsample data
            descriptorData = transpose(descriptorData);
            % calculate k means
            obj.codebooks{1} = vl_ikmeans(descriptorData, FeaturedImage.k1); % k = 500
            obj.codebooks{2} = vl_ikmeans(descriptorData, FeaturedImage.k2); % k = 1000

            % combine descriptor
            descriptorData = featuredImageDB(1).colorDescriptor;
            for i = 2 : dbSize
                descriptorData = [descriptorData featuredImageDB(i).colorDescriptor];
            end

            descriptorData = transpose(descriptorData);
            descriptorData = downsample(descriptorData,30); % subsample data
            descriptorData = transpose(descriptorData);
            % calculate k means
            obj.codebooks{3} = vl_ikmeans(descriptorData, FeaturedImage.k1); % k = 500
            obj.codebooks{4} = vl_ikmeans(descriptorData, FeaturedImage.k2); % k = 1000

            % combine descriptor
            descriptorData = featuredImageDB(1).descriptor_192;
            for i = 2 : dbSize
                descriptorData = [descriptorData featuredImageDB(i).descriptor_192];
            end

            descriptorData = transpose(descriptorData);
            descriptorData = downsample(descriptorData,30); % subsample data
            descriptorData = transpose(descriptorData);
            % calculate k means
            obj.codebooks{5} = vl_ikmeans(descriptorData, FeaturedImage.k1); % k = 500
            obj.codebooks{6} = vl_ikmeans(descriptorData, FeaturedImage.k2); % k = 1000

            % init bag of words for each image
            for i = 1 : dbSize
              featuredImageDB(i) = featuredImageDB(i).initVisualWords( obj.codebooks{1}, obj.codebooks{2}, obj.codebooks{3}, obj.codebooks{4}, obj.codebooks{5}, obj.codebooks{6}); 
            end
            
            % init database as image data
            for i = 1 : dbSize
                db(i) = featuredImageDB(i).imageData;
            end
            
            obj.database = db;
        end
        
        function [dbIndexes] = nearestNeigborSearch(obj, imageToSearch, type)
        %nearestNeigborSearch seach image over database
        %   dbIndexes = db.nearestNeigborSearch(imageToSearch, type)
        %   imageToSearch: ImageData. use createImageData( obj, imagePath, imageLabel)
        %   to get data from image.
        %   type: type of search. 1: gradient k = 500, 2: gradient k = 1000,
        %   3: color k = 500, 4: color k = 1000, 5: combined k = 500, 6:
        %   combined k = 1000
        %   return closest image indexes in database

                distances = Inf(1, size(obj.database,2));

                % find distances
                for i = 1 : size(obj.database,2)
                    distances(i) = sum( minus(obj.database(i).visualWords{type}, imageToSearch.visualWords{type}).^2, 2 );
                end

                % sort distances and return indexes
                [~, indexes] = sort(distances);
                dbIndexes = indexes;
        end
        
        function [imageData] = createImageData( obj, imagePath, imageLabel)
        %createImageData creates data from image.
        %   imageData = db.createImageData(imagePath, imageLabel)
        %   image path: string image path
        %   image label: number image label
        %   returns ImageData
        
            featuredImage = FeaturedImage(imagePath, imageLabel); % create featured image
            % init bag of words
            featuredImage = featuredImage.initVisualWords( obj.codebooks{1}, obj.codebooks{2}, obj.codebooks{3}, obj.codebooks{4}, obj.codebooks{5}, obj.codebooks{6}); 
            imageData = featuredImage.imageData;
        end
        
        function [means, K10Scores] = evaluate( obj, queryImages,queryLabels, type)
        %evaluate performance
        %   [means, K10Scores] = db.evaluate( queryImages, queryLabels, type)
        %   queryImages: cell array of string image paths
        %   queryLabels: array of labels
        %   queryImages and galleryLabels must have same size
        %   type: type of search. 1: gradient k = 500, 2: gradient k = 1000,
        %   3: color k = 500, 4: color k = 1000, 5: combined k = 500, 6:
        %   combined k = 1000
        %   returns means: overall ratio for k values between 1 ant 100
        %           K10Scores: score for each label and overall score for K =10

            querySize = size(queryImages, 2);

            imagesToSearch(1, querySize) = ImageData; % create array

            % create ImageData
            for i = 1 : querySize
                imagesToSearch(i) = obj.createImageData( string(queryImages(i)), queryLabels(i));
            end

            % evaluate k = 1 to 100
            means = zeros(1, 100);

            for K = 1 : 100
                precision = zeros(1, querySize);

                for i = 1 : querySize

                    indexes = obj.nearestNeigborSearch( imagesToSearch(i), type); % search image
                    % check label hits
                    hit = 0;
                    for j = 1 : K 
                        if obj.database( indexes(j) ).label == imagesToSearch(i).label
                            hit = hit + 1;
                        end
                    end

                    precision(i) = hit / K; % take average
                end

                means(K) = mean(precision); % take average for each label
                if K == 10
                    K10 = means(K); % store K = 10
                end
            end

            % evaluate K = 10
            K = 10;
            K10Scores = zeros(1, 11); % create array
            K10Scores(11) = K10; % set overall value
            precision = zeros(1, 10);
            labelIndex = 1; % for different labels
            for i = 1 : querySize

                indexes = obj.nearestNeigborSearch( imagesToSearch(i), type);
                % check label hits
                hit = 0;
                for j = 1 : K 
                    if obj.database( indexes(j) ).label == imagesToSearch(i).label
                        hit = hit + 1;
                    end
                end

                precision(labelIndex) = hit / K;
                labelIndex = labelIndex + 1;

                % new label
                if labelIndex == 11
                     K10Scores( i / 10 ) = mean(precision);
                     precision = zeros(1, 10);
                     labelIndex = 1;
                end
            end

        end
    end
    
    methods(Static)
        function [queryImages,galleryImages,queryLabels,galleryLabels] = createRandomImages(dataPath, txtPath)
            %createRandomImages select random 10 images for each category
            %from dataset provided in course webpage
            %   [queryImages,galleryImages,queryLabels,galleryLabels] = createRandomImages(dataPath)
            %   dataPath: path for data folder. e.g. '../data/' for folder above current folder of this class
            %   txtPath: path for folder that stores txt files. e.g. '../txt/' for folder above current folder of this class
            
            gallery_images_file = fopen([txtPath 'gallery_images.txt'], 'w');
            query_images_file = fopen([txtPath 'query_images.txt'], 'w');
            gallery_labels_file = fopen([txtPath 'gallery_labels.txt'], 'w');
            query_labels_file = fopen([txtPath 'query_labels.txt'], 'w');

            randomImages = [];
            randIndex = 1;
            galleryIndex = 1;
            galleryImages = {};
            queryImages = {};

            % select random images
            for i = 1 : 10
                randomImages = [randomImages randperm(100, 10)+((i-1) * 100 - 1)];
            end

            randomImages = sort(randomImages);

            for i = 0:999
                if i < 100
                    folder = 'africa';
                    label = 1;
                elseif i < 200
                    folder = 'beach';
                    label = 2;
                elseif i < 300
                    folder = 'buildings';
                    label = 3;
                elseif i < 400
                    folder = 'buses';
                    label = 4;
                elseif i < 500
                    folder = 'dinosaurs';
                    label = 5;
                elseif i < 600
                    folder = 'elephants';
                    label = 6;
                elseif i < 700
                    folder = 'flowers';
                    label = 7;
                elseif i < 800
                    folder = 'horses';
                    label = 8;
                elseif i < 900
                    folder = 'mountains';
                    label = 9;
                else
                    folder = 'food';
                    label = 10;
                end

                % if query image
                if randIndex < 101 && i == randomImages(randIndex)
                    queryImages{randIndex} = sprintf('%s%s/%d.jpg',dataPath,folder,i);
                    fprintf(query_images_file, [queryImages{randIndex} '\n']);

                    queryLabels(randIndex) = label;
                    fprintf(query_labels_file, '%d\n', label);

                    randIndex = randIndex + 1;
                % if gallery image
                else
                    galleryImages{galleryIndex} = sprintf('%s%s/%d.jpg',dataPath,folder,i);
                    fprintf(gallery_images_file, [galleryImages{galleryIndex} '\n']);

                    galleryLabels(galleryIndex) = label;
                    fprintf(gallery_labels_file, '%d\n', label);

                    galleryIndex = galleryIndex + 1;
                end
            end

            fclose(gallery_images_file);
            fclose(query_images_file);
            fclose(gallery_labels_file);
            fclose(query_labels_file);
        end

        function [queryImages,galleryImages,queryLabels,galleryLabels] = readFiles( query_images_path, gallery_images_path, query_labels_path, gallery_labels_path)
        %readFiles read path and label files
        %   [queryImages,galleryImages,queryLabels,galleryLabels] = ( query_images_path, gallery_images_path, query_labels_path, gallery_labels_path)
        %   e.g. readFiles( 'query_images.txt', 'gallery_images.txt', 'query_labels.txt', 'gallery_labels.txt' )

            gallery_images_file = fopen(gallery_images_path, 'r');
            query_images_file = fopen(query_images_path, 'r');
            gallery_labels_file = fopen(gallery_labels_path, 'r');
            query_labels_file = fopen(query_labels_path, 'r');

            % cell arrays
            galleryImages = {};
            queryImages = {};

            % read line by line
            i = 1;
            line = fgetl(gallery_images_file);
            while ischar(line)
                galleryImages{i} = line;
                line = fgetl(gallery_images_file);
                i = i + 1;
            end

            % read line by line
            i = 1;
            line = fgetl(query_images_file);
            while ischar(line)
                queryImages{i} = line;
                line = fgetl(query_images_file);
                i = i + 1;
            end

            galleryLabels = fscanf(gallery_labels_file, '%d'); % scan labels
            queryLabels = fscanf(query_labels_file, '%d'); % scan labels

            galleryLabels = transpose(galleryLabels); % column vector
            queryLabels = transpose(queryLabels); % column vector

            fclose(gallery_images_file);
            fclose(query_images_file);
            fclose(gallery_labels_file);
            fclose(query_labels_file);

        end 
        
    end
end