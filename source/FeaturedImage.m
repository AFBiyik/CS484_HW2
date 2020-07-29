% Author: Ahmet Furkan Biyik
% ID: 21501084
% Date: 23.11.2019

classdef FeaturedImage
    %FeaturedImage image analysis class for CBIR
    properties (Constant)
        k1 = 500; % kmeans k
        k2 = 1000; % kmeans k
    end
    
    properties
        image; % image
        keyPoints; % sift output
        gradientDescriptor;
        colorDescriptor;
        descriptor_192; % combined descriptor
        imageData; % significant image data
    end
    
    methods
        function obj = FeaturedImage(path, label)
            %FeaturedImage constructor
            %   path: string path of image
            %   label: label of image
            %   obj = FeaturedImage('../data/africa/0.jpg', 1)
            if nargin == 2
                obj.imageData = ImageData(); % init image data
                obj.imageData.path = path; % set path
                obj.imageData.label = label; % set label
                obj.imageData.visualWords = cell(1, 6); % create empty cell array for cisual words
                obj.image = imread( path); % read image
                obj = obj.initDescriptors(); % initialize descriptor
            end
        end
        
        function obj = initVisualWords(obj, codebooks1, codebooks2, codebooks3, codebooks4, codebooks5, codebooks6)
            %initVisualWords initialize bag of words representation of the
            %image.
            %   obj = initVisualWords( codebooks1, codebooks2, codebooks3, codebooks4, codebooks5, codebooks6)
            %   codebooks1: kmeans centers for gradient descriptor with k = FeaturedImage.k1
            %   codebooks2: kmeans centers for gradient descriptor with k = FeaturedImage.k2
            %   codebooks3: kmeans centers for color descriptor with k = FeaturedImage.k1 
            %   codebooks4: kmeans centers for color descriptor with k = FeaturedImage.k2
            %   codebooks5: kmeans centers for combined descriptor with k = FeaturedImage.k1
            %   codebooks6: kmeans centers for combined descriptor with k = FeaturedImage.k2
            
            % initialize each visual words
            obj.imageData.visualWords{1} = obj.bagOfWords(codebooks1, obj.gradientDescriptor);
            obj.imageData.visualWords{2} = obj.bagOfWords(codebooks2, obj.gradientDescriptor);
            obj.imageData.visualWords{3} = obj.bagOfWords(codebooks3, obj.colorDescriptor);
            obj.imageData.visualWords{4} = obj.bagOfWords(codebooks4, obj.colorDescriptor);
            obj.imageData.visualWords{5} = obj.bagOfWords(codebooks5, obj.descriptor_192);
            obj.imageData.visualWords{6} = obj.bagOfWords(codebooks6, obj.descriptor_192);
        end
       
    end
    
    methods (Access = private)
        function obj = initDescriptors(obj)
            %initDescriptors initialize features
            
            gray = rgb2gray(obj.image); % grayscale image
            gray = im2single(gray); % uint8 to single
            [obj.keyPoints, obj.gradientDescriptor] = vl_sift(gray); % sift
            obj = obj.initColorDescriptor( obj.image, obj.keyPoints); % init color features
            obj.descriptor_192 = vertcat(obj.gradientDescriptor, obj.colorDescriptor); % combined features
        end
        
        function obj = initColorDescriptor(obj, img, kp)
            %initColorDescriptor initialize color features
            %   image: image
            %   kp: key points
            rows = size(img, 1);
            columns = size(img, 2);
            
            features = size(kp,2);
            colorDesc = uint8(zeros(64,features)); % init with zero
            
            for f = 1 : features
                
                % keypoint
                x = kp(1,f);
                y = kp(2,f);
                scale = kp(3,f);
                radius = kp(4,f);
                
                % count pixels
                rgbHist = zeros(4,4,4);
                
                for horizontal = 0 : ceil(2*scale)
                    for vertical = 0 : ceil(2*scale)
                        
                        x1 = horizontal - scale;
                        y1 = vertical - scale;
                        
                        x2 = floor(x1 * cos(radius) - y1 * sin(radius) + x);
                        y2 = floor(x1 * sin(radius) + y1 * cos(radius) + y);
                        
                        if (y2 > 0 && x2 > 0 && y2 < rows && x2 < columns)
                            rBin = idivide(img(y2, x2, 1), 64, 'floor') + 1;
                            gBin = idivide(img(y2, x2, 2), 64, 'floor') + 1;
                            bBin = idivide(img(y2, x2, 3), 64, 'floor') + 1;
                            rgbHist(rBin, gBin, bBin) = rgbHist(rBin, gBin, bBin) + 1;
                        end
                    end
                end
                
                colorDesc(:,f) = reshape(rgbHist,[64,1]); % change shape and assign
            end
            
            obj.colorDescriptor = colorDesc;
        end
        
        function bag = bagOfWords(obj, codebook, descriptor)
            %bagOfWords create bag of words representation of the image
            %   codebook: kmeans centers.
            %   descriptor to assign
            
            % convert to single
            sc = single(codebook); 
            sd = single(descriptor);
            
            ids = zeros(1, size(sd,2), 'int32');
            
            for i= 1:size(sd,2)
                ds = sum( bsxfun(@minus, sc, sd(:,i)).^2, 1 ); % find distance
                [~, indexes] = sort(ds); % sort
                ids(:,i) = indexes(1:1); % assign to min distance
            end
            
            bag = hist( double(ids), 1:size(codebook,2) ); % count
        end
    end
end
