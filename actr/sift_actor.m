classdef sift_actor < actor
    %SIFT_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        appearance_time 	    % defined in actor
        faces
        
        sifts_frontal    % average of sifts used
        sifts_profile    % 
    end
    
    methods
        function obj = sift_actor( track_facedets )            
            pose                   = cat(1, track_facedets.pose);
            frontal                = (pose == 1);
            profile                = (pose ~= 1);
            track_facedets_frontal = track_facedets(frontal);
            track_facedets_profile = track_facedets(profile);
            
            if length(track_facedets_frontal) > 1
                image_num   = track_facedets_frontal(1).frame;
                face_rect   = track_facedets_frontal(1).rect;
            else
                image_num   = track_facedets(1).frame;
                face_rect   = track_facedets(1).rect; 
            end
            face(1:4,1) = face_rect';
            face(5,1)   = image_num;
            
            obj.faces            = face; 
            obj.appearance_time  = length( track_facedets(profile) ) ...
                                 + length( track_facedets(frontal) );
            
            if ~isempty( track_facedets_frontal )
                front_sifts = cat(2, track_facedets_frontal.dSIFT);
                obj.sifts_frontal = front_sifts;
            end
            
            if ~isempty( track_facedets_profile )
                prof_sifts = cat(2, track_facedets_profile.dSIFT);
                obj.sifts_profile = prof_sifts;
            end
        end
        
        function obj = train( obj, other )
            prevTime = obj.appearance_time;
            newTime  = obj.appearance_time + other.appearance_time;
            
            if ~isempty( other.sifts_frontal )
                obj.sifts_frontal = cat(2, obj.sifts_frontal, other.sifts_frontal) ;
            end
            
            if ~isempty( other.sifts_profile ) 
                obj.sifts_profile = cat(2, obj.sifts_profile, other.sifts_profile) ;
            end
            
            new_faces = other.faces;
            obj.faces = cat(2, obj.faces, new_faces);
            obj.appearance_time = newTime;
        end
        
        function diff = get_model_diff( obj, other )
            diff = 200;
            if ~isempty( obj.sifts_frontal ) && ~isempty( other.sifts_frontal )
                min = intmax('int32');
                for i = 1 : size(obj.sifts_frontal, 2)
                    % nearest-point search; find nearest face
                    [~,d] = dsearchn(other.sifts_frontal', obj.sifts_frontal(:, i)');
                    if d < min
                        min = d;
                    end
                end
                diff = min;
            else
                % only compare profile faces if frontal face is missing
                if ~isempty( obj.sifts_profile ) && ~isempty( other.sifts_profile )
                    min = intmax('int32');
                    for i = 1 : size(obj.sifts_profile, 2)
                        % nearest-point search; find nearest face
                        [~,d] = dsearchn(other.sifts_profile', obj.sifts_profile(:, i)');
                        if d < min
                            min = d;
                        end
                    end
                    diff = min;
                end
            end
        end
        
        function show_faces( obj )
           num_faces = size(obj.faces, 2);
           for i = 1:num_faces
               face_rect = obj.faces(1:4, i);
               image_num = obj.faces(5, i);
               img = imread(sprintf('./dump/%09d.jpg', image_num));
               face = imcrop(img, [face_rect(1) face_rect(3) face_rect(2) ...
                    - face_rect(1) face_rect(4) - face_rect(3)] );
               subplot(4, 4, i);
               imshow(face);
           end
        end
    end
    
end