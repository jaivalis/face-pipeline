classdef sift_actor_conf < actor
    %SIFT_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        appearance_time
        faces       % defined in actor
        pconf_avg   % defined in actor
        pconf_angles       % defined in actor
        dsifts      % defined in actor
        appearing_frames
        track_id
        name
    end
    
    methods
        function obj = sift_actor_conf( track_facedets, shot_id )
            [obj.faces, obj.dsifts, obj.pconf_avg, obj.pconf_angles, ...
                obj.appearing_frames, obj.track_id]...
                = obj.get_face_details( track_facedets, shot_id );
            obj.appearance_time = length( track_facedets );
        end
        
        function obj = train( obj, other )
            prevTime = obj.appearance_time;
            newTime  = prevTime + other.appearance_time;
            
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
        
        function diff = get_min_min_diff( obj, other )
            a = (obj.pconf_angles ~= -200);
            b = (other.pconf_angles ~= -200);
            c = bsxfun(@and, a, b);
            common_angles = find(c > 0);
            if isempty( common_angles ) || obj.overlap( other )
                diff = 200;
            else
                t_sift = obj.dsifts(:, common_angles);
                o_sift = other.dsifts(:, common_angles);
                result = abs(t_sift - o_sift);
                result1 = sum(result);
                % find min diff
                diff = result1(find(result1 == min(result1)));
                if length(diff) > 1
                    diff = diff(1);
                end
            end
            %for i = 1 : length( t_sift )

                %TODO: weigth features differently
                
            %end
        end
        
        function diff = get_weighted_average_diff( obj, other )
            a = (obj.pconf_angles ~= -200);
            b = (other.pconf_angles ~= -200);
            c = bsxfun(@and, a, b);
            common_angles = find(c > 0);
            if isempty( common_angles ) || obj.overlap( other )
                diff = 200;
            else
                % weight vector
                % w = [ .3 .4 .5 .6 .9 .9 1 .9 .9 .6 .5 .4 .3 ];
                w = [ .8 .7 .6 .5 .4 .3 .2 .3 .4 .5 .6 .7 .8 ];
                t_sift = obj.dsifts(:, common_angles);
                o_sift = other.dsifts(:, common_angles);
                result = abs(t_sift - o_sift);
                % weight angles by importance, assign more weight to front
                result1 = sum(result) * w(common_angles)';
                % normalize difference by common_angles
                diff = sum(result1) / length(common_angles);
            end
            %for i = 1 : length( t_sift )
                %TODO: weigth features differently  
            %end
        end
        
        function diff = get_average_diff( obj, other )
            a = (obj.pconf_angles ~= -200);
            b = (other.pconf_angles ~= -200);
            c = bsxfun(@and, a, b);
            common_angles = find(c > 0);
            if isempty( common_angles ) || obj.overlap( other )
                diff = 200;
            else
                t_sift = obj.dsifts(:, common_angles);
                o_sift = other.dsifts(:, common_angles);
                result = abs(t_sift - o_sift);
                result1 = sum(result);
                % normalize difference by common_angles
                diff = sum(result1) / length(common_angles);
            end
        end
        
        function diff = get_frontal_diff( obj, other )
            if ( sum( obj.dsifts(:, 7) ) == 0 &&  sum( other.dsifts(:, 7) ) == 0 ) || ...
                obj.overlap( other )
                diff = 200;
            else
                t_sift = obj.dsifts(:, 7);
                o_sift = other.dsifts(:, 7);
                result = abs(t_sift - o_sift);
                diff = sum(result);
            end
        end
        
        function diff = get_eyes_nose_diff( obj, other )
            % only compare dsifts for eyes and nose
            % siftdescriptors for eyes and nose are:
            % [ 1 2 3 4 5 6 7 10 11 13 14 15 16 17 18 19 22 23 ]
            temp_obj = reshape(obj.dsifts, 128, 24, 13);
            temp_other = reshape(other.dsifts, 128, 24, 13);
            eyes_nose_obj = cat(1, temp_obj(:, 1, :), temp_obj(:, 2, :), temp_obj(:, 3, :), temp_obj(:, 4, :)...
                , temp_obj(:, 5, :), temp_obj(:, 6, :), temp_obj(:, 7, :), temp_obj(:, 10, :)...
                , temp_obj(:, 11, :), temp_obj(:, 13, :), temp_obj(:, 14, :), temp_obj(:, 15, :)...
                , temp_obj(:, 16, :), temp_obj(:, 17, :), temp_obj(:, 18, :), temp_obj(:, 19, :)...
                , temp_obj(:, 22, :), temp_obj(:, 23, :));
            eyes_nose_other = cat(1, temp_other(:, 1, :), temp_other(:, 2, :), temp_other(:, 3, :), temp_other(:, 4, :)...
                , temp_other(:, 5, :), temp_other(:, 6, :), temp_other(:, 7, :), temp_other(:, 10, :)...
                , temp_other(:, 11, :), temp_other(:, 13, :), temp_other(:, 14, :), temp_other(:, 15, :)...
                , temp_other(:, 16, :), temp_other(:, 17, :), temp_other(:, 18, :), temp_other(:, 19, :)...
                , temp_other(:, 22, :), temp_other(:, 23, :));
            a = (obj.pconf_angles ~= -200);
            b = (other.pconf_angles ~= -200);
            c = bsxfun(@and, a, b);
            common_angles = find(c > 0);
            if isempty( common_angles ) || obj.overlap( other )
                diff = 200;
            else
                t_sift = eyes_nose_obj(:, 1, common_angles);
                o_sift = eyes_nose_other(:, 1, common_angles);
                result = abs(t_sift - o_sift);
                result1 = sum(result);
                diff = result1(find(result1 == min(result1)));
                if length(diff) > 1
                    diff = diff(1);
                end
                % normalize difference by common_angles
                % diff = sum(result1) / length(common_angles);
            end
        end
        
        function obj = merge( obj, other )
%             for i = 1:size( other.track_id, 1 )
%                 if  other.track_id(i,1) == 4 && other.track_id(i,2) == 2
%                     'a';
%                 end
%             end
%             
%             for i = 1:size( obj.track_id, 1 )
%                 if  obj.track_id(i,1) == 4 && obj.track_id(i,2) == 2
%                     'a';
%                 end
%             end
            % merge sifts
            % save disifts of face with higher confidence
            for i = 1 : length( obj.pconf_angles )
                if obj.pconf_angles(i) < other.pconf_angles(i) && ...
                        other.pconf_angles(i) ~= -200
                    % keep other(i)
                    obj.pconf_angles(i) = other.pconf_angles(i);
                    obj.faces(:, i)     = other.faces(:, i);
                    obj.dsifts(:, i)    = other.dsifts(:, i);
                end
            end
            % sum appearance time
            obj.appearance_time  = obj.appearance_time + ...
                        other.appearance_time;
            % concat appearing frames
            obj.appearing_frames = cat( 1, obj.appearing_frames,...
                        other.appearing_frames );
            obj.track_id = cat( 1, obj.track_id, other.track_id );
        end
        
        function c = overlap( obj, other )
            c = ~ isempty(intersect(obj.appearing_frames, other.appearing_frames));
        end
        
    end
end