classdef LSH < handle % handle -> convert class from value to handle/pass-by-reference class
    % Random Projection Locally Sensitive [feature] Hashing (LSH) implementation based on:
    % - [1][python]: https://gist.github.com/greeness/94a3d425009be0f94751
    % - [2][JS port]: https://gist.github.com/sepans/419d413f786b27872b34
    % - [3][Wikipedia]: https://en.wikipedia.org/wiki/Locality-sensitive_hashing
    %
    % "Locality-sensitive hashing (LSH) reduces the dimensionality of 
    %  high-dimensional data. LSH hashes input items so that similar items 
    %  map to the same “buckets” with high probability (the number of 
    %  buckets being much smaller than the universe of possible input 
    %  items). LSH differs from conventional and cryptographic hash 
    %  functions because it aims to maximize the probability of a 
    %  “collision” for similar items. Locality-sensitive hashing has much 
    %  in common with data clustering and nearest neighbor search."[3]
    
    properties
%         randomProjection;   % Random projection which maps input to output
    end
    
    methods(Static)
        % Get uniform random vector between [-1, 1] of size [outputsize, inputsize]
        function rndProj = getRandomProjection(inputSize, outputSize)
            rndProj = -1+2*rand(outputSize, inputSize);
        end
        
        % LSH signature generation using random projections
        function signature = getSignature(randomProjection, data)
            signature = ((randomProjection*data)>=0); % dot product of randomProjection rows and data + binarization 
        end
        
        % Hash similarity 
        function hashSim = hashSimilarity(signature1, signature2)
            dims = size(signature1, 1); % Dimensions
            xorVec = xor(signature1, signature2);
            nnzVal = nnz(xorVec);
            hashSim = (dims-nnzVal)/dims;
        end
        
        % angular similarity using definitions
        % http://en.wikipedia.org/wiki/Cosine_similarity
        function angularSim = angularSimilarity(data1, data2)
            dotVal = dot(data1, data2);
            sum1 = sum(data1.^2)^0.5;
            sum2 = sum(data2.^2)^0.5;
            cosVal = dotVal/(sum1*sum2);
            thetaVal = acos(cosVal);
            angularSim = 1.0-(thetaVal/pi);
        end
    end
    
    methods
        % Constructor
        function lsh = LSH()
            % Do nothing
        end
        
        % Example (implementation) function
        function outputArg = example(lsh)
            dim = 200;  % Number of data features 
            d = 2^10;   % Number of bits per signature
            rndProj = LSH.getRandomProjection(dim, d);
            runs = 1000;
            avg = 0;
            tic     % Start timer
            for it=1:runs
                user1 = -1+2*rand(dim, 1);  % a 1xdim random vector
                user2 = -1+2*rand(dim, 1);  % a 1xdim random vector
                sig1 = LSH.getSignature(rndProj, user1);
                sig2 = LSH.getSignature(rndProj, user2);
                hashSim = LSH.hashSimilarity(sig1, sig2);
                angularSim = LSH.angularSimilarity(user1, user2);
                diff = abs(angularSim-hashSim);
                avg = avg + diff;
                disp([' angularSim: ',num2str(angularSim), ' hashSim: ', num2str(hashSim), ' diff: ', num2str(diff)]);
            end
            disp(['Average diff: ', num2str(avg/runs)]);
            toc     % display time
        end
    end
end

