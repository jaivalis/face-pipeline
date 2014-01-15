classdef svm_actor < actor
    %SVM_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        appearance_time 	    % inherited from actor
        faces                   % inherited from actor
        
        front_svm           % frontal view classifier 
        side1_svm           % side view classifier
        side2_svm           % side view classifier
        front_training_data   % used instead of online learning
        side1_training_data   % used instead of online learning
        side2_training_data   % used instead of online learning
        front_training_labels % used instead of online learning
        side1_training_labels % used instead of online learning
        side2_training_labels % used instead of online learning
    end
    
    methods
        function obj = svm_actor( track_facedets )
            pose                 = cat(1, track_facedets.pose);
            front                = (pose == 1);
            side1                = (pose == 2);
            side2                = (pose == 3);
            track_facedets_front = track_facedets(front);
            track_facedets_side1 = track_facedets(side1);
            track_facedets_side2 = track_facedets(side2);
            
            image_num   = track_facedets(1).frame;
            face_rect   = track_facedets(1).rect;
            face(1:4,1) = face_rect';
            face(5,1)   = image_num;

            obj.faces            = face;
            obj.appearance_time  = length( track_facedets(front) ) ...
                                 + length( track_facedets(side1) ) ...
                                 + length( track_facedets(side2) );
            
            if ~isempty( track_facedets_front )
                dSifts              = cat( 2, track_facedets_front.dSIFT );
                obj.front_training_data   = dSifts;
                obj.front_training_labels = ones(size(dSifts, 2), 1);
                obj.front_svm = svmtrain( obj.front_training_labels, dSifts', '-b 1 -q' );
            end
            
            if ~isempty( track_facedets_side1 )
                dSifts        = cat( 2, track_facedets_side1.dSIFT );
                obj.side1_training_data   = dSifts;
                obj.side1_training_labels = ones(size(dSifts, 2), 1);
                obj.side1_svm = svmtrain( obj.side1_training_labels, dSifts', '-b 1 -q' );
            end
            
            if ~isempty( track_facedets_side2 )
                dSifts        = cat( 2, track_facedets_side2.dSIFT );
                obj.side1_training_data   = dSifts;
                obj.side1_training_labels = ones(size(dSifts, 2), 1);
                obj.side1_svm = svmtrain( obj.side1_training_labels, dSifts', '-b 1 -q' );
            end
        end
        
        function obj = train( obj, other, label )
            prevTime = obj.appearance_time;
            newTime  = prevTime + other.appearance_time;
            
            track_facedets_front = other.front_training_data;
            track_facedets_side1 = other.side1_training_data;
            track_facedets_side2 = other.side2_training_data;
            
            front_other_count = size(track_facedets_front, 2);
            side1_other_count = size(track_facedets_side1, 2);
            side2_other_count = size(track_facedets_side2, 2);
            
            if front_other_count > 0
                dSifts                     = track_facedets_front;
                
                if isempty( obj.front_training_data )
                    obj.front_training_data = other.front_training_data;
                else
                    obj.front_training_data = cat( 2, obj.front_training_data, dSifts );
                end
                
                new_label = ones(1, size(dSifts, 2)) * label;
                obj.front_training_labels = cat( 1, obj.front_training_labels, new_label' );
                obj.front_svm = svmtrain( obj.front_training_labels, obj.front_training_data', '-b 1 -q' );
            end
            
            if side1_other_count > 0
                dSifts                  = track_facedets_side1;
                
                if isempty( obj.side1_training_data )
                    obj.side1_training_data = other.side1_training_data;
                else
                    obj.side1_training_data = cat( 2, obj.side1_training_data, dSifts );
                end
                
                new_label = ones(1, size(dSifts, 2)) * label;
                obj.side1_training_labels = cat( 1, obj.side1_training_labels, new_label' );
                obj.side1_svm = svmtrain( obj.side1_training_labels, obj.side1_training_data', '-b 1 -q' );
            end
            
            if side2_other_count > 0
                dSifts                  = track_facedets_side2;
                
                if isempty( obj.side2_training_data )
                    obj.side2_training_data = other.side2_training_data;
                else
                    obj.side2_training_data = cat( 2, obj.side2_training_data, dSifts );
                end
                
                new_label = ones(1, size(dSifts, 2)) * label;
                obj.side2_training_labels = cat( 1, obj.side2_training_labels, new_label' );
                obj.side2_svm = svmtrain( obj.side2_training_labels, obj.side2_training_data', '-b 1 -q' );
            end
            
            if label == 1
                new_faces = other.faces;
                obj.faces = cat(2, obj.faces, new_faces);
                obj.appearance_time = newTime;
            end
        end
        
        function diff = get_model_diff( obj, other )

            track_facedets_front = other.front_training_data;
            track_facedets_side1 = other.side1_training_data;
            track_facedets_side2 = other.side2_training_data;
            
            front_obj_count = length(obj.front_training_data);
            side1_obj_count = length(obj.side1_training_data);
            side2_obj_count = length(obj.side2_training_data);
            
            front_other_count = length(track_facedets_front);
            side1_other_count = length(track_facedets_side1);
            side2_other_count = length(track_facedets_side2);
            
            front_pred = 0;
            side1_pred = 0;
            side2_pred = 0;
            if front_obj_count > 0 && front_other_count > 0
                label_v = rand( track_facedets_front, 1);

                % TODO use prob_est
                [labl, ~, prob_est] = ...
                  svmpredict(label_v, track_facedets_front, obj.front_svm , '-b 1 -q');
                
                front_pred = sum(labl) / front_other_count;
            end
            
            if side1_obj_count > 0 && side1_other_count > 0
                label_v = rand(length(track_facedets_side1), 1);
                
                [labl, ~, prob_est] = ...
                  svmpredict(label_v, track_facedets_side1, obj.front_svm , '-b 1 -q');
              
                side1_pred = sum(labl) / front_other_count;
            end
            
            if side1_obj_count > 0 && side2_other_count > 0
                label_v = rand(length(track_facedets_side2), 1);
                
                [labl, ~, prob_est] = ...
                  svmpredict(label_v, track_facedets_side2, obj.front_svm , '-b 1 -q');
                
                side2_pred = sum(labl) / front_other_count;
            end
            
            confidence = front_pred*.6 + side1_pred*.2 + side2_pred*.2;
            diff = 1 - confidence;
        end
    end
    
end

