classdef sift_actor < actor
    %SIFT_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        appearance_time 	    % inherited from actor
        faces                   % inherited from actor
        
        sift_average_frontal    % average of sifts used
        sift_average_profile    % 
    end
    
    methods
        function obj = sift_actor( track_facedets )
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
                face_cat = cat(2, track_facedets_frontal.dSIFT);
                if length(track_facedets_frontal) > 1
                    average_f = sum(face_cat')'/length(track_facedets_frontal);
                else
                    average_f = track_facedets_frontal.dSIFT;
                end
                obj.sift_average_frontal = average_f;
            end
            
            if ~isempty( track_facedets_profile )
                face_cat = cat(2,track_facedets_profile.dSIFT);
                if length(track_facedets_profile) > 1
                    average_p = sum(face_cat')' / length(track_facedets_profile);
                else
                    average_p = track_facedets_profile.dSIFT;
                end
                obj.sift_average_profile = average_p;
            end
        end
        
        function obj = train( obj, other )
            prevTime = obj.appearance_time;
            newTime  = obj.appearance_time + other.appearance_time;
            
            if ~isempty( other.sift_average_frontal )
                if isempty( obj.sift_average_frontal )
                    obj.sift_average_frontal = other.sift_average_frontal;
                else                
                    obj.sift_average_frontal = obj.sift_average_frontal * prevTime ...
                        + other.sift_average_frontal * other.appearance_time;
                    obj.sift_average_frontal = obj.sift_average_frontal / (newTime);
                end
            end
            
            if ~isempty( other.sift_average_profile )
                if isempty( obj.sift_average_profile )
                    obj.sift_average_profile = other.sift_average_profile;
                else
                    obj.sift_average_profile = obj.sift_average_profile * prevTime ...
                        + other.sift_average_profile * other.appearance_time;
                    obj.sift_average_profile = obj.sift_average_profile / (newTime);
                end
            end
            
            new_faces = other.faces;
            obj.faces = cat(2, obj.faces, new_faces);
            obj.appearance_time = newTime;
        end
        
        function diff = get_model_diff( obj, other )
            frontal_diff = intmax('int32');
            if ~isempty( obj.sift_average_frontal ) && ~isempty( other.sift_average_frontal )
                d = abs(obj.sift_average_frontal - other.sift_average_frontal );
                frontal_diff = sum(d);
            end
            
            profile_diff = intmax('int32');
            if ~isempty( obj.sift_average_profile ) && ~isempty( other.sift_average_profile ) 
                d = abs(obj.sift_average_profile - other.sift_average_profile );
                frontal_diff = sum(d);
            end
            diff = min(frontal_diff, profile_diff);
        end
        
    end
    
end