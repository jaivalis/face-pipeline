classdef sift_actor_conf < actor
    %SIFT_ACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        appearance_time
        faces       % defined in actor
        pconf_avg   % defined in actor
        pconf_angles       % defined in actor
        dsifts      % defined in actor
    end
    
    methods
        function obj = sift_actor_conf( track_facedets )
            [obj.faces, obj.dsifts, obj.pconf_avg, obj.pconf_angles] = obj.get_face_details( track_facedets );
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
            a = (obj.pconf_angles ~= 0);
            b = (other.pconf_angles ~= 0);
            c = bsxfun(@and, a, b);
            common_angles = find(c > 0);
            if isempty( common_angles )
                diff = 200;
            else
                t_sift = obj.dsifts(:, common_angles);
                o_sift = other.dsifts(:, common_angles);
                result = abs(t_sift - o_sift);
                result1 = sum(result);
                % find min diff
                diff = result1(find(result1 == min(result1)));
            end
            %for i = 1 : length( t_sift )
                %TODO: weigth features differently
                
            %end
        end
        
        function diff = get_average_diff( obj, other )
            a = (obj.pconf_angles ~= 0);
            b = (other.pconf_angles ~= 0);
            c = bsxfun(@and, a, b);
            common_angles = find(c > 0);
            if isempty( common_angles )
                diff = 200;
            else
                t_sift = obj.dsifts(:, common_angles);
                o_sift = other.dsifts(:, common_angles);
                result = abs(t_sift - o_sift);
                result1 = sum(result);
                % normalize difference by common_angles
                diff = sum(result1) / length(common_angles);
            end
            %for i = 1 : length( t_sift )
                %TODO: weigth features differently
                
            %end
        end
        
        function obj = merge( obj, other )
            % merge sifts
            % savedisifts of face with higher confidence
            for i = 1 : length( obj.pconf_angles )
                if obj.pconf_angles(i) < other.pconf_angles(i)
                    % keep other(i)
                    obj.pconf_angles(i) = other.pconf_angles(i);
                    obj.faces(:, i)     = other.faces(:, i);
                    obj.dsifts(:, i)    = other.dsifts(:, i);
                end
            end
            % sum appearance time
            obj.appearance_time  = obj.appearance_time + ...
                        other.appearance_time;
        end
        
    end
end