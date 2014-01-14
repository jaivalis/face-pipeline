classdef svm_actor < actor
    %SVM_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
        appearance_time 	    % inherited from actor
        faces                   % inherited from actor
        
        front_svm           % frontal view classifier 
        sidev_svm           % side view classifier
        front_training_data   % used instead of online learning
        sidev_training_data   % used instead of online learning
        true_label  =  1
        fals_label  = -1
    end
    
    methods
        function obj = svm_actor( track_facedets )
            pose                   = cat(1, track_facedets.pose);
            frontal                = (pose == 1);
            profile                = (pose ~= 1);
            track_facedets_frontal = track_facedets(frontal);
            track_facedets_profile = track_facedets(profile);
            
            image_num   = track_facedets(1).frame;
            face_rect   = track_facedets(1).rect;
            face(1:4,1) = face_rect';
            face(5,1)   = image_num;
            
            obj.faces            = face;
            obj.appearance_time  = length( track_facedets(profile) ) ...
                                 + length( track_facedets(frontal) );
            
            if ~isempty( track_facedets_frontal )
                dSifts              = cat( 2, track_facedets_frontal.dSIFT );
                obj.front_training_data = dSifts;
                obj.front_svm = svmtrain( ones(1, length(dSifts)), dSifts', '-b 1 -q' );
            end
            
            if ~isempty( track_facedets_profile )
                dSifts        = cat( 2, track_facedets_profile.dSIFT );
                obj.sidev_training_data = dSifts;
                obj.sidev_svm = svmtrain( ones(1, length(dSifts)), dSifts', '-b 1 -q' );
            end
            
        end
        
        function train( obj, other, label )
            prevTime = obj.appearance_time;
            newTime  = obj.appearance_time + other.appearance_time;
            
            if ~isempty( other.sift_average_frontal )
                if isempty( obj.sift_average_frontal )
                    obj.front_training_data = other.front_training_data;
                else
                    obj.front_training_data = cat( 2, obj.front_training_data, dSifts );
                end
                training_label = ones(1, length(dSifts)) * label;
                obj.front_svm = svmtrain( training_label, obj.front_training_data', '-b 1 -q' );
            end
            
            if ~isempty( other.sift_average_profile )
                if isempty( obj.sift_average_frontal )
                else
                end
            end
            
            new_faces = other.faces;
            obj.faces = cat(2, obj.faces, new_faces);
            obj.appearance_time = newTime;
        end
        
        function conf = get_confidence( obj, other )
        %GET_RESEMBLANCE Returns the score the actor's classifier returns
        %for the given facedet
            conf = 0;
            switch ( facedet.pose )
                case 1
                    % train frontal classifier


                case 2
                case 3
                    % train classifier 2
                    

            end
        end
    end
    
end

