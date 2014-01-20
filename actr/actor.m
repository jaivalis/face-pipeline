classdef actor
%ACTOR
%

    properties (Abstract, Access = public)
        appearance_time   % expressed in frame count
        faces
    end
    
    methods 

    end
    
    methods (Abstract)
        train( obj, other )
        %TRAIN Trains the classifier on the given track
        % INPUT
        % + obj  : this
        % + other: track to train from
        
        get_model_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
        
        compare_models( obj, other ) %TODO remove this method
        %COMPARE_MODELS compare two siftactors and return sorted confidence
        % vector
        % INPUT
        % + obj  : this
        % + other: actors to compare with
        
        merge( obj, other )
        %MERGE Merges two actors to a new actor object
        % INPUT
        % + obj  : this
        % + other: actors to compare with
    end
    
    methods
        function show_faces( obj )
        %SHOW_FACES Plot the faces used for training the actor classifier
           num_faces = size(obj.faces, 2);
           for i = 1:num_faces
               face_rect = obj.faces(1:4, i);
               image_num = obj.faces(5, i);
               img = imread(sprintf('./dump/%09d.jpg', image_num));
               face = imcrop(img, [face_rect(1) face_rect(3) face_rect(2) ...
                    - face_rect(1) face_rect(4) - face_rect(3)] );
               subplot(ceil(num_faces/ 2) , 2, i);
               imshow(face);
               title(sprintf('App time %d', obj.appearance_time));
           end
        end

    end
    
end