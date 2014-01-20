classdef sift_actor_conf < actor
    %SIFT_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        appearance_time 	    % defined in actor
        faces
        
        sift_frontal    % sifts of face with hightest confidence of track
        sift_profile    % 
    end
    
    methods
        function obj = sift_actor_conf( track_facedets )
            tr = track_facedets;
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
                
                obj.sift_frontal(:, 1) = track_facedets_frontal(max_conf).dSIFT;
            end
            
            if ~isempty( track_facedets_profile )
                face_conf = cat(1, track_facedets_profile.conf);
                max_conf = find(face_conf ==(max(max(face_conf))));
                
                obj.sift_profile(:, 1) = track_facedets_profile(max_conf).dSIFT;
            end
        end
        
        function obj = train( obj, other )
            prevTime = obj.appearance_time;
            newTime  = obj.appearance_time + other.appearance_time;
            
            if ~isempty( other.sift_frontal )
                ins = size(obj.sift_frontal, 2);
                obj.sift_frontal(:, ins + 1) = other.sift_frontal;
            end
            
            if ~isempty( other.sift_profile ) 
                ins = size(obj.sift_profile, 2);
                obj.sift_profile(:, ins + 1) = other.sift_profile;
            end
            
            new_faces = other.faces;
            obj.faces = cat(2, obj.faces, new_faces);
            obj.appearance_time = newTime;
        end
        
        function diff = get_model_diff( obj, other )
            diff = 200;
            if ~isempty( obj.sift_frontal ) && ~isempty( other.sift_frontal )
                min = intmax('int32');
                for i = 1 : size(obj.sift_frontal, 2)
                    % nearest-point search; find nearest face
                    [~,d] = dsearchn(other.sift_frontal', obj.sift_frontal(:, i)');
                    if d < min
                        min = d;
                    end
                end
                diff = min;
            else
                % only compare profile faces if there's a frontal face
                % missing
                if ~isempty( obj.sift_profile ) && ~isempty( other.sift_profile )
                    min = intmax('int32');
                    for i = 1 : size(obj.sift_profile, 2)
                        % nearest-point search; find nearest face
                        [~,d] = dsearchn(other.sift_profile', obj.sift_profile(:, i)');
                        if d < min
                            min = d;
                        end
                    end
                    diff = min;
                end
            end
        end
        
        function [diff, actors_tree] = compare_models( obj, all, comp_type )
            index = 1;
            l = length(all);
            diff = ones(l, 2) * 200;
            for track = 1:l
                if ~isempty( obj.sift_frontal ) && ~isempty( all(track).sift_frontal )
                    min = intmax('int32');
                    for i = 1 : size(obj.sift_frontal, 2)
                        % nearest-point search; find nearest face
                        [~,d] = dsearchn(all(track).sift_frontal', obj.sift_frontal(:, i)');
                        if d < min
                            min = d;
                        end
                    end
                    diff(index, 1) = min;
                    diff(index, 2) = track;
                else
                    % only compare profile faces if frontal face is missing
                    if ~isempty( obj.sift_profile ) && ~isempty( all(track).sift_profile )
                        min = intmax('int32');
                        for i = 1 : size(obj.sift_profile, 2)
                            % nearest-point search; find nearest face
                            [~,d] = dsearchn(all(track).sift_profile', obj.sift_profile(:, i)');
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
            % find 0 in diff and replace it with 200
            zer = find(diff(:, 1) == 0);
            diff(zer) = 200;
            if strcmp(comp_type, 'weighted_conf')
                % sort diff
                diff = sortrows(diff, 1);
                % multiply groups of 5 with weight
                weight = 0.8;
                for p = 1:size(diff, 1)
                    if mod(p - 1, 3) == 0
                        weight = weight + 0.2;
                    end
                    diff(p, 1) = diff(p, 1) * weight;
                end
            end
            actors_tree = diff(:, 2);
            diff = diff(:, 1);
        end

        
        function obj = merge( obj, other )
            % merge sifts
            o_sifts_f = other.sift_frontal;
            o_sifts_p = other.sift_profile;
            if ~isempty( o_sifts_f )
                front_sifts = cat(2, obj.sift_frontal, o_sifts_f);
                obj.sift_frontal = front_sifts;
            end
            
            if ~isempty( o_sifts_p )
                prof_sifts = cat(2, obj.sift_profile, o_sifts_p);
                obj.sift_profile = prof_sifts;
            end
            
            % sum appearance time
            obj.appearance_time = obj.appearance_time + other.appearance_time;
            
            % add faces
            obj.faces = cat(2, obj.faces, other.faces);
        end
    end
    
end