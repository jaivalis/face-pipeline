classdef actor
%ACTOR
%
    properties (Abstract, Access = public)
        appearance_time   % expressed in frame count
        faces
        pconf_avg % average pconf of track
        pconf_angles   % vector per face confidence
        dsifts
        appearing_frames % vector of frames IDs actor is appearing in
        track_id % vector of track id actor is appearing in
    end
    
    methods (Abstract)
        train( obj, other )
        %TRAIN Trains the classifier on the given track
        % INPUT
        % + obj  : this
        % + other: track to train from
        
        get_min_min_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
        
        get_average_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
        
        get_frontal_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
        
        get_eyes_nose_diff( obj, other )
        %GET_CONFIDENCE returns the score a given track receives for
        %resemblance to this actor [0, 1]
        % INPUT
        % + obj  : this
        % + other: actor to compare with
        
        merge( obj, other )
        %MERGE Merges two actors to a new actor object
        % INPUT
        % + obj  : this
        % + other: actors to compare with
    end
    
    methods (Access = public)
        function show_faces( obj, dump_dir )
        %SHOW_FACES Plot the faces used for training the actor classifier
           for i = 1:length(obj.faces)
               face_rect = obj.faces(1:4, i);
               image_num = obj.faces(5, i);
              if image_num == 0
                   continue;
               end
               img = imread(fullfile(dump_dir, sprintf('%09d.jpg', image_num)));
               face = imcrop(img, [face_rect(1) face_rect(3) face_rect(2) ...
                    - face_rect(1) face_rect(4) - face_rect(3)] );
               if obj.faces(6, i) == 1
                   face = face(:,end:-1:1,:);
               end
               subplot(3 , 5, i);
               imshow(face);
               title(num2str(obj.get_angles(i)));
           end
        end

        function [faces, dsifts, pconf_avg, pconf_angles, appearing_frames, track_id] ...
                = get_face_details( obj, track_facedets, shot_id )
            pconf = cat(1, track_facedets.pconf);
            pconf_avg = sum(pconf) / length(pconf);
            
            pconf_angles = ones(13, 1) * -200;
            faces = zeros(5, 13);
            dsifts = zeros(3072, 13);
            
            max_confs_ind =  obj.get_max_confs_indexes( track_facedets );

            for i = 1:length( max_confs_ind )
                max_ind = max_confs_ind( i );
                if max_ind == -1 % this angle was not found
                    continue;
                end
                faces(1:4, i) = track_facedets( max_ind ).rect;
                faces(5, i) = track_facedets( max_ind ).frame;
                faces(6, i) = 0;
                pconf_angles(i) = track_facedets( max_ind ).pconf;
                % if profile, concat zeros
                if length(track_facedets( max_ind ).dSIFT) == 1792
                    temp = reshape(track_facedets( max_ind ).dSIFT, 128,14);
                    % convert dsifts from profile to frontal:
                    % 0 0 2 1
                    % 0 3 4 0
                    % 5 0 7 0
                    % 0 0 9 8
                    % 0 10 11 0
                    % 12 0 14 0
                    fd = cat(1, zeros(128, 1), zeros(128, 1), temp(:, 2), temp(:, 1),...
                        zeros(128, 1), temp(:, 3), temp(:, 4), zeros(128, 1),...
                        temp(:, 5), zeros(128, 1), temp(:, 7), zeros(128, 1),...
                        zeros(128, 1), zeros(128, 1), temp(:, 9), temp(:, 8),...
                        zeros(128, 1), temp(:, 10), temp(:, 11), zeros(128, 1),...
                        temp(:, 12), zeros(128, 1), temp(:, 14), zeros(128, 1));
                    
                    dsifts(:, i)      = fd;
                else
                    dsifts(:, i)      = track_facedets( max_ind ).dSIFT;
                end
            end
            appearing_frames = cat(1, track_facedets.frame);
            track_id(1)      = shot_id;
            track_id(2)      = track_facedets(1).track;
            % mirror descriptors and images to find details for not
            % existent angles
            [faces, dsifts, pconf_angles] =  obj.mirror(faces, dsifts, pconf_angles);
        end
        
        function [f, ds, p_angl] = mirror( obj, faces, dsifts, pconf_angles )
            f = faces;
            ds = dsifts;
            p_angl = pconf_angles;
            mir_i = [13 12 11 10 9 8 7 6 5 4 3 2 1];
            a = pconf_angles ~= -200;
            mirrored_a = fliplr(a')';
            c = bsxfun(@and, mirrored_a, ~a);
            indexes_to_write = find(c > 0);
            for i = indexes_to_write
                ds(:, i)  = ds(:, mir_i(i));
                f(:, i)   = faces(:, mir_i(i));
                % mirrored flag
                f(6, i)   = 1;
                % penalize mirrored face
                p_angl(i) = pconf_angles(mir_i(i)) * 0.8;
                '';
            end
        end

        function indexes = get_max_confs_indexes( obj, track_facedets )
        % index to track_facedets with the highest confidence per angle
            max_confs = zeros(1, 13) - 200;
            indexes   = zeros(1, 13) - 1;

            for i = 1 : length(track_facedets)
                if length(track_facedets) == 16
                    'b';
                end
                    
                index = obj.get_index( track_facedets(i, 1).head_pose );

                if max_confs( index ) < track_facedets(i, 1).pconf
                    max_confs( index ) = track_facedets(i, 1).pconf;
                    indexes( index )   = i;
                end
            end
        end

        function index = get_index(obj, head_pose)
            switch head_pose
                case -90,  index = 1;
                case -75,  index = 2;
                case -60,  index = 3;
                case -45,  index = 4;
                case -30,  index = 5;
                case -15,  index = 6;
                case 0,    index = 7;
                case 15,   index = 8;
                case 30,   index = 9;
                case 45,   index = 10;
                case 60,   index = 11;
                case 75,   index = 12;
                case 90,   index = 13;
                otherwise, index = -1;
            end
        end
        
        function head_pose = get_angles(obj, index)
            switch index
                case 1,      head_pose = -90;
                case 2,      head_pose = -75;
                case 3,      head_pose = -60;
                case 4,      head_pose = -45;
                case 5,      head_pose = -30;
                case 6,      head_pose = -15;
                case 7,      head_pose = 0;
                case 8,      head_pose = 15;
                case 9,      head_pose = 30;
                case 10,     head_pose = 45;
                case 11,     head_pose = 60;
                case 12,     head_pose = 75;
                case 13,     head_pose = 90;
                otherwise,   head_pose = -1;
            end
        end
        
        function face = get_representative( obj, angle )
           index = obj.get_index( angle );
           if obj.faces(5, index) == 0
               'b';
           end
           if obj.faces(5, index) == 0
               'b';
           end
           img = imread(sprintf('./dump/%09d.jpg', obj.faces(5, index)));
           face_rect = obj.faces(1:4, index);
           face = imcrop(img, [face_rect(1) face_rect(3) face_rect(2) ...
                - face_rect(1) face_rect(4) - face_rect(3)] );
           if obj.faces(6, index) == 1
               face = face(:,end:-1:1,:);
           end
        end

    end
    
end