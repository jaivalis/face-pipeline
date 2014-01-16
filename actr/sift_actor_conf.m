classdef sift_actor_conf < actor
    %SIFT_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        appearance_time 	    % defined in actor
        faces
        
        sift_max_conf_frontal    % average of sifts used
        sift_max_conf_profile    % 
    end
    
    methods
        function obj = sift_actor_conf( track_facedets )            
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
                face_conf = cat(1, track_facedets_frontal.conf);
                max_conf = find(face_conf ==(max(max(face_conf))));
                
                obj.sift_max_conf_frontal(:, 1) = track_facedets_frontal(max_conf).dSIFT;
            end
            
            if ~isempty( track_facedets_profile )
                face_conf = cat(1, track_facedets_profile.conf);
                max_conf = find(face_conf ==(max(max(face_conf))));
                
                obj.sift_max_conf_profile(:, 1) = track_facedets_profile(max_conf).dSIFT;
            end
        end
        
        function obj = train( obj, other )
            prevTime = obj.appearance_time;
            newTime  = obj.appearance_time + other.appearance_time;
            
            if ~isempty( other.sift_max_conf_frontal )
                ins = size(obj.sift_max_conf_frontal, 2);
                obj.sift_max_conf_frontal(:, ins + 1) = other.sift_max_conf_frontal;
            end
            
            if ~isempty( other.sift_max_conf_profile ) 
                ins = size(obj.sift_max_conf_profile, 2);
                obj.sift_max_conf_profile(:, ins + 1) = other.sift_max_conf_profile;
            end
            
            new_faces = other.faces;
            obj.faces = cat(2, obj.faces, new_faces);
            obj.appearance_time = newTime;
        end
        
        function diff = get_model_diff( obj, other )
            diff = 200;
            if ~isempty( obj.sift_max_conf_frontal ) && ~isempty( other.sift_max_conf_frontal )
                min = intmax('int32');
                for i = 1 : size(obj.sift_max_conf_frontal, 2)
                    % nearest-point search; find nearest face
                    [~,d] = dsearchn(other.sift_max_conf_frontal', obj.sift_max_conf_frontal(:, i)');
                    if d < min
                        min = d;
                    end
                end
                diff = min;
            else
                % only compare profile faces if there's a frontal face
                % missing
                if ~isempty( obj.sift_max_conf_profile ) && ~isempty( other.sift_max_conf_profile )
                    min = intmax('int32');
                    for i = 1 : size(obj.sift_max_conf_profile, 2)
                        % nearest-point search; find nearest face
                        [~,d] = dsearchn(other.sift_max_conf_profile', obj.sift_max_conf_profile(:, i)');
                        if d < min
                            min = d;
                        end
                    end
                    diff = min;
                end
            end
        end
        
        function [diff, actors_tree] = compare_models( obj, all )
            index = 1;
            l = length(all);
            diff = ones(l, 2) * 200;
            for track = 1:l
                if ~isempty( obj.sift_max_conf_frontal ) && ~isempty( all(track).sift_max_conf_frontal )
                    min = intmax('int32');
                    for i = 1 : size(obj.sift_max_conf_frontal, 2)
                        % nearest-point search; find nearest face
                        [~,d] = dsearchn(all(track).sift_max_conf_frontal', obj.sift_max_conf_frontal(:, i)');
                        if d < min
                            min = d;
                        end
                    end
                    diff(index, 1) = min;
                    diff(index, 2) = track;
                else
                    % only compare profile faces if frontal face is missing
                    if ~isempty( obj.sift_max_conf_profile ) && ~isempty( all(track).sift_max_conf_profile )
                        min = intmax('int32');
                        for i = 1 : size(obj.sift_max_conf_profile, 2)
                            % nearest-point search; find nearest face
                            [~,d] = dsearchn(all(track).sift_max_conf_profile', obj.sift_max_conf_profile(:, i)');
                            if d < min
                                min = d;
                            end
                        end
                        diff(index, 1) = min;
                        diff(index, 2) = track;
                    end
                end
                % some models can't be compared yet, since only frontal or only
                % profile exist. Compare after merging again?
                % TODO: think about a way to work around this
                if diff(index, 1) == 200
                    diff(index, 2) = track;
                end
                index = index + 1;
            end
            % sort diff
            diff = sortrows(diff, 1);
            % delete first row, since the difference of a model with itself
            % is zero and we only want to compare with all other models
            diff = diff(2:l,:);
            actors_tree = diff(:, 2);
            diff = diff(:, 1);
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